//#!/usr/local/bin/tcc -run
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <sys/mman.h>
#include <sys/stat.h>

static int deep_debug = 0;
char const* help =	\
	"Usage: bpar [xd] DATA.BP ...\n"	\
	"       bpar id DATA.BP NEKO.KSC ..."	\
	"\nArguments:\n"	\
	"   -x\t\tExtract the .BP{M,} archive.\n"	\
	"   -i\t\tInject a file into the .BP{M,} archive.\n"	\
	"   -c\t\tCreate the .BP{M,} archive. DON'T USE THIS.\n"	\
	"   -d\t\tGo deeper. If you are inspecting game files, use this.";

// Useful for debugging
struct common_header
{
	short s;//ize
	unsigned char magic[12];
} common_headers[] = {
	{ .s = 8, .magic = { 'D', 'A', 'K', 0, 0xFD, 0xB8, 0x73, 0x77 }},
	{ .s = 8, .magic = { 'D', 'V', 'S', 0, 0xFD, 0xB8, 0x73, 0x77 }},
	{ .s = 5, .magic = { 'A', 'S', 'C', 0, 0x10 }},
	{ .s = 4, .magic = { 'X', 'F', 'T', '1' }},
	{ .s = 4, .magic = { 'B', '2', 'A', '0' }},
	{ .s = 4, .magic = { 'N', 'J', 'D', 'C' }},
	{ .s = 4, .magic = { 'R', 'I', 'F', 'F' }}, // .a0, shouldn't be here anyway!
	{ .s = 8, .magic = { 0x89, 'P', 'N', 'G', 13, 10, 26, 10 }}, // lol?
	{ .s = 8, .magic = { 'P', 'S', 'M', 'F', 0x30, 0x30, 0x31, 0x32 }},
	{ .s = 8, .magic = { 0, 0, 0, 0, 0, 0, 0, 0, }}, // ???? fuck yourselves
	{ .s = 11, .magic = { 'M', 'I', 'G', 0x2E, 0x30, 0x30, 0x2E, 0x31, 'P','S','P' }},
	{ .s = 4, .magic = { 0xA2, 0, 0, 0x90 }}, // .DIC
	{ .s = 3, .magic = { 'K', 'S', 'C' }},
	{ .s = -1 },
};

unsigned verify = 1;

// Stores MMAP'd data into a memory buffer. May increase speed.
#define MMAP_MEMCPY 1

#ifdef DEBUG
#	define DEBUGF printf
#else
#	define DEBUGF(...) ;
#endif

// You'd get tired of typing this shit too
typedef unsigned char uchar;

// mmap'd memory goes here
char const* F_name;
uchar* F = NULL;
size_t F_size = 0;
uchar* F_head = NULL;
#ifdef MMAP_MEMCPY
	uchar* F_map;
#endif
void F_close();

unsigned char FF[4] = { 0xFF, 0xFF, 0xFF, 0xFF };
	
struct opts
{
	short c/*reate*/ : 1;
	// TODO It's not always deep. This is seen in Let's Gakkou!
	short d/*eep*/   : 1;
	short x/*tract*/ : 1;
	short i/*nject*/ : 1;
} opts = { 0 };

struct bp_filepack_header
{
	unsigned num_files,
	         file_info,
	         filenames_length,
	         header_size;
	uchar* initial_pos; // Worth noting!
};

struct bp_file
{
	unsigned offset;
	char* filename; // free(filename)
	unsigned filename_offset;
	unsigned filesize;
	uchar* data;
};

unsigned
dec_uint(unsigned char* arr, size_t len)
{
	unsigned res = 0;
	for (size_t i = 0; i < len; ++i)
	{
		res |= arr[i] << (i*8);
	}
	return res;
}

void
enc_uint(unsigned long value, size_t length, unsigned char* data)
{
    for (unsigned i = 0; i < length; ++i)
        data[i] = (value >> (i * 8)) & 0xFF;
}

// Prints out hex dump, file position, etc.
void
debug()
{
	return;
	uchar* initial_pos = F_head;
	DEBUGF("=================== Debug : %08u ===================\n|  ", initial_pos);
	

	for (int i = 0; i < 16 * 6; ++i)
	{
		int last = i != (16 * 6) - 1;
		DEBUGF("%02hhX %s", initial_pos[i], (i+1) % 4 == 0 && last ? " " : "");
		
		if ((i+1) % 16 == 0 && last)
			DEBUGF("| \n|  ");
	}
	
	DEBUGF(" |\n========================================================\n");
}

void
debugfp(FILE* FP, int offset)
{
	long initial_pos = ftell(FP);
	printf("=================== Debug : %08u ===================\n|  ", ftell(FP));
	

	fseek(FP, -offset, SEEK_CUR);
	
	for (int i = 0; i < 16 * 7; ++i)
	{
		int last = i != (16 * 7) - 1;
		printf("%s%02hhX %s", i == 0 ? "\x1b[31m" : "",
		       fgetc(FP), (i+1) % 4 == 0 && last ? " " : "");
		
		if ((i+1) % 16 == 0 && last)
			printf("\x1b[0m| \n|  ");
	}
	fseek(FP, offset, SEEK_CUR);
	
	printf(" |\n========================================================\n");
	fseek(FP, initial_pos, SEEK_SET);
}



// NOTE internally uses path, works fine for this program
void
nested_mkdir(char* path, mode_t mode)
{
	for (int i = 0; i < strlen(path); ++i)
	{
		if (path[i] == '/')
		{
			path[i] = '\0';
			mkdir(path, mode);
			path[i] = '/';
		}
	}
	// Always makes the last one
	mkdir(path, mode);
}

char*
unixdir_to_windir(char* filename)
{
	for (int i = 0; i < strlen(filename); ++i)
		if (filename[i] == '/')	filename[i] = '\\';
	return filename;
}

char*
windir_to_unixdir(char* filename)
{
	for (int i = 0; i < strlen(filename); ++i)
		if (filename[i] == '\\') filename[i] = '//';
	return filename;
}

long
fsize(FILE* FP)
{
	long _ = ftell(FP);
	fseek(FP, 0, SEEK_END);
	long new_size = ftell(FP);
	fseek(FP, _, SEEK_SET);
	return new_size;
}

int
verify_magic(FILE* FP)
{
	int ret = 1;
	for (struct common_header* hdr = common_headers;
	      hdr->s != -1 && ret != 0;
	      ++hdr)
	{
		unsigned char magic[12];
		fread(magic, 1, hdr->s, FP); 
		
		if (memcmp(magic, hdr->magic, hdr->s) == 0)
		{
			ret = 0;
		}
		fseek(FP, -(hdr->s), SEEK_CUR);
	}
	if (ret == 1)
	{
		puts("UNKNOWN MAGIC HEADER!!!");
		debugfp(FP, 0);
		puts("Just a heads up!");
		//exit(1);
	}
	return ret;
}

// Not what meets the eye. Attempts to look at the path, create dirs, then file
void
create_file(struct bp_file* file, char* data)
{
	int nested = 0;
	// Dup for manipulation
	char* filename = strdup(file->filename);
	puts(filename);
	for (int i = 0; i < strlen(filename); ++i)
		if (filename[i] == '\\')
			{ filename[i] = '/'; nested = 1; }
		else if (filename[i] == '/')
			nested = 1; // You Stupid Fucking Bitch. (this is with Let's Gakkou)
	
	if (nested)
	{
		// Go backwards and find the first '\';
		char* x = strrchr(filename, '/');
		unsigned i = x - filename;
		
		filename[i] = '\0';
		/////////
		nested_mkdir(filename, 0700);
		///////// Revert back to file path
		filename[i] = '/';
	}
	
	DEBUGF("Writing to %s...\n", filename);

#if 0	
	// Slower, currently contained.
	int fd = open(filename, O_RDWR | O_CREAT, 0600);
	ftruncate(fd, file->filesize);
	//printf("file->filesize: %d\n", file->filesize);
	char* map = mmap(0, file->filesize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(map, data, file->filesize);
	close(fd);
	munmap(map, file->filesize);
#endif
	FILE* outfile = fopen(filename, "w+");
	if (!outfile)
	{
		printf("fopen: %s: %s\n", filename, strerror(errno));
		free(filename);
		return;
	}
	
	if (file->filesize > 0)
		fwrite(data, 1, file->filesize, outfile);
	
	if (verify)
	{
		fseek(outfile, 0, SEEK_SET);
		verify_magic(outfile);
	}
	
	fclose(outfile);
cleanup:
	free(filename);
}

size_t
read_filepack_header(struct bp_filepack_header* hd,
                     struct bp_file** files)
{
	*files = NULL;
	size_t f = 0; // files counter
	// Need for return and seek...
	hd->initial_pos = F_head;
	
	hd->num_files = dec_uint(F_head, 4);
	hd->file_info = dec_uint(F_head+4, 4);
	hd->filenames_length = dec_uint(F_head+8, 4);
	hd->header_size = dec_uint(F_head+12,4);
	F_head += 16;
	
	DEBUGF("[ Entering filepack header ]");
	
	//DEBUGF("%d\n", hd->file_info);
	//fseek(FP, file_info*16, SEEK_CUR);
	for (unsigned i = 0; i < hd->file_info; ++i)
	{
		if (F_head[0] == 0xFF && F_head[1] == 0xFF)
		{
			//fseek(FP, 4, SEEK_CUR);
			F_head += 16;
			continue;
		};
		/* Attempt allocation every 12 files (this might not matter due to Malloc arenas
			but hey it's whatever... */
		*files = realloc(*files, sizeof(struct bp_file) * (f + 1));
		(*files)[f].filename_offset = dec_uint(F_head, 4);
		F_head += 4;
		unsigned offset;
		(*files)[f].offset = offset = dec_uint(F_head, 4);
		F_head += 4;
		unsigned filesize;
		(*files)[f].filesize = filesize = dec_uint(F_head, 4);
		DEBUGF("filesize: %d at offset %d\n", filesize, offset);
		if ((int)filesize < 0 || (int)offset < 0)
		{
			puts("Filesize too large! Archive corrupt, aborting...");
			puts("------------------------------------------------");
			printf("hd->file_info: %d\n", hd->file_info);
			printf("hd->header_size: %d\n", hd->header_size);
			printf("deep: %d\n", deep_debug);
			exit(2);
		}
		F_head += 8;
		++f;
	}
	debug();
	return f;
}

/* NOTE This function could be merged with the above, but
 *  it was nicer to keep it separate... just incase... */
void
read_filenames(struct bp_file* files, unsigned len)
{
	debug();
	for (int i = 0; i < len; ++i)
	{
		// Do we really need to make a gap here?
		files[i].filename = strdup(F_head + files[i].filename_offset);
	}
#if 0
	for (int i = 0; strlen(F_head) != 0; ++i)
	{
		files[i].filename = strdup(F_head);
		F_head += strlen(F_head)+1;
	}
#endif
	debug();
}

void
header_seek_begin(struct bp_filepack_header* hd)
{
	F_head = hd->initial_pos;
	F_head += hd->header_size;
	//fseek(FP, hd->initial_pos, SEEK_SET);
	//fseek(FP, hd->header_size, SEEK_CUR);
}

/* Why can't we go deeper than 1 recurse? Well, we technically could...
 *  but the issue lies in the fact that there is no magic number for .BP(M)
 *  files, so they definitely weren't intended to be nested beyond one.
 *
 * If there was a magic number of some sort, we could identify and recurse
 *  into the next filepack header. We could definitely do some tricks to identify
 *  it too, but I suppose it would be overengineered since we never really
 *  need to go deeper than one recurse. */
void
read_files(unsigned deep)
{
	uchar* initial_pos = F_head;
	//////
	struct bp_file* files;
	struct bp_filepack_header header;
	deep_debug = deep;
	size_t files_len = read_filepack_header(&header, &files);
	read_filenames(files, files_len);
	
	for (int i = 0; i < files_len; ++i)
	{
		header_seek_begin(&header);
		//fseek(FP, files[i].offset, SEEK_CUR); // Go to file
		F_head += files[i].offset;
		
		DEBUGF("Filename: %s - Filesize: %d at offset %d\n",
		       files[i].filename, files[i].filesize, (int)F_head - (int)F);
		
		
		if (deep)
			read_files(0);
		else {
			uchar* data = files[i].data = F_head;
		
			create_file(files + i, data);
			debug();
		}
	}
	// TODO loop through and free filenames and such
	//free(files);
	//////
	F_head = initial_pos;
}

/**
 * Deeply reads dir and adds files.
 *
 * \param offset  String offset to exclude from .BP{M,} file.
 * \param output  Output file for packing.
 * \param dirname Directory to read.
 * \param files	  Files.
 * \param i       Files length.
 */
#if 0
void // TODO reupdate for realloc, not like it's used 
deep_readdir(int offset, char* output, char* dirname, struct bp_file** files, size_t* i)
{
	DIR* derp = opendir(dirname);
	struct dirent* dp;
	while ((dp = readdir(derp)) != NULL)
	{
		if (strcmp(dp->d_name, ".") == 0 || strcmp(dp->d_name, "..") == 0) continue;
		char* filename;
		asprintf(&filename, "%s/%s", dirname, dp->d_name);
		DIR* d = opendir(filename);
		if (d)
		{
			DEBUGF("<D>: %s [stepping]\n", filename);
			deep_readdir(offset, output, filename, files, i);
			closedir(d);
			
			//DEBUGF("Is dir: %s\n", dp->d_name);
		}
		else {
			files[*i].filename = unixdir_to_windir(strdup(filename + offset));
			
			// Read contents
			struct stat s;
			FILE* outfile = fopen(filename, "r");
			stat(filename, &s);
			uchar* data = files[*i].data = malloc(files[*i].filesize = s.st_size);
			// Reading a lot of data
			fread(data, 1, s.st_size, outfile);
			fclose(outfile);
			
			DEBUGF(" F : %s\n", filename);
			++*i;
		}
		free(filename);
	}
}
#endif

void
create_bp_archive(char const* output,
                  struct bp_file* files,
                  size_t len)
{
	puts("Sony Ninjas have been dispatched to your location.\n\n"	\
	     "Use injection.");
	exit(42);
	
#if 0
	FILE* FP = fopen(output, "w");
	
	// Create filenames data
	unsigned char filenames[555555] = { 0 };
	int filenames_len = 0;
	for (int i = 0, pos = 0; i < len; 
	      (filenames_len += strlen(files[i].filename)+1, ++i))
	{
		memcpy(filenames + filenames_len, files[i].filename, strlen(files[i].filename)+1);
		;
	}
	
	// SEC: Initial header
	unsigned char buf[4];
	enc_uint(len, 4, buf);
	fwrite(buf, 1, 4, FP);
	
	enc_uint(len, 4, buf);
	fwrite(buf, 1, 4, FP);
	
	enc_uint(filenames_len, 4, buf);
	fwrite(buf, 1, 4, FP);
	
	// We'll go back to these later
	long head_size_pos = ftell(FP);
	enc_uint(len, 4, buf);
	fwrite(buf, 1, 4, FP);
	
	// SEC: File info
	size_t fn_size_offset = 0,
	       f_size_offset = 0;
	for (int i = 0; files[i].filename != NULL; ++i)
	{
		enc_uint(fn_size_offset, 4, buf);
		fwrite(buf, 1, 4, FP);
		enc_uint(f_size_offset, 4, buf);
		fwrite(buf, 1, 4, FP);
		enc_uint(files[i].filesize, 4, buf);
		fwrite(buf, 1, 4, FP);
		fwrite(FF, 1, 4, FP);
		f_size_offset += files[i].filesize;
		fn_size_offset += strlen(files[i].filename)+1;
		//fwrite(files[i].filename, 1, strlen(files[1].filename)+1, FP);
		//fwrite(files[i].data, 1, files[i].filesize, FP);
	}
	// SEC: File names
	fwrite(filenames, 1, filenames_len, FP);
	
	// Go back to head size position, write data
	long data_pos = ftell(FP);
	fseek(FP, head_size_pos, SEEK_SET);
	enc_uint(data_pos, 4, buf);
	fwrite(buf, 1, 4, FP);
	fseek(FP, data_pos, SEEK_SET);
	
	// SEC: Data
	for (int i = 0; files[i].filename != NULL; ++i)
	{
		fwrite(files[i].data, 1, files[i].filesize, FP);
	}
	fclose(FP);
#endif
}

/* TODO I'm repeating quite a bit of fileheader parsing. Perhaps I could
 *  utilize function pointers or state in some way to not write as much code soon? */
void
inject_update_offsets(FILE* FP,
                      const const* real_filename,
                      unsigned new_origin_size,
                      char const* origin,
                      struct bp_file* origin_file,
                      struct bp_file* deep_file)
{
	long o_pos = ftell(FP);
	uchar buf[4];
	if (new_origin_size > origin_file->filesize)
	{
		fread(buf, 1, 4, FP);
		unsigned num_files = dec_uint(buf, 4);
		fseek(FP, 8, SEEK_CUR);
		//fseek(FP, 12, SEEK_CUR);
		fread(buf, 1, 4, FP);
		unsigned fileheader_size = dec_uint(buf, 4);
		unsigned o_data = o_pos + fileheader_size;
		
		for (int i = 0; i < num_files; ++i)
		{
			// Not interested in filename
			//fseek(FP, 4, SEEK_CUR);
			fread(buf, 1, 4, FP);
			if (buf[0] == 0xFF && buf[1] == 0xFF)
			{
				--i;
				continue;
			}
			
			// Get offset
			fread(buf, 1, 4, FP);
			unsigned offset = dec_uint(buf, 4);

			struct bp_file* _file = deep_file ? deep_file : origin_file;
			
			if (_file == origin_file && origin_file->offset == offset)
				printf("Found Self : %d\n", i);
			
			int new_size_diff = new_origin_size - origin_file->filesize;
			if (_file && offset > _file->offset)
			{
				printf("Shifting %d - %s of %u files", i, _file->filename, num_files);
				printf(" - Size %d at offset %d\n", new_size_diff, offset);
				debugfp(FP, 8);

				// We need to adjust the offset to account for the earlier offset added
				enc_uint(offset + new_size_diff, 4, buf);
				printf("OLD : %d | NEW : %d\n", offset, offset + new_size_diff);
				fseek(FP, -4, SEEK_CUR);
				fwrite(buf, 1, 4, FP);
				
				//debugfp(FP, 8); 
				
				fseek(FP, 8, SEEK_CUR);
				
				
				continue;
			}
			
			if (_file && offset == _file->offset)
			{
				printf("Self : %d at offset %u\n", i, offset);

				debugfp(FP, 8);
				
				if (deep_file)
				{
					enc_uint(deep_file->filesize + new_size_diff, 4, buf);
					
					long o_pos_2 = ftell(FP);
					fseek(FP, o_data + offset, SEEK_SET);
					inject_update_offsets(FP, real_filename, new_origin_size,
					                      origin, origin_file, NULL);
					fseek(FP, o_pos_2, SEEK_SET);
				}
				else {
					enc_uint(new_origin_size, 4, buf);
				}
				fwrite(buf, 1, 4, FP);
				debugfp(FP, 12);
					
				fseek(FP, 4, SEEK_CUR);
			}
			else
				fseek(FP, 8, SEEK_CUR);
		}
	}
}

void
inject_to_new_file(char const* real_filename,
                   char const* origin,
                   struct bp_file* origin_file,
                   struct bp_file* deep_file)
{
	FILE* new_origin = fopen(real_filename, "r");
	long new_origin_size = fsize(new_origin);
	
	// Intentionally using fwrite / fread here because he can easily append
	FILE* outfile = fopen("/tmp/bpar_work", "w+");
	
	int entry_point = (int)F_head - (int)F;
	// Read everything up to here
	fwrite(F, 1, entry_point, outfile);
	
	// BEGIN Read the new file into tmp file
	char* tmpptr = malloc(new_origin_size);
	fread(tmpptr, 1, new_origin_size, new_origin);
	fwrite(tmpptr, 1, new_origin_size, outfile);
	free(tmpptr);
	fclose(new_origin);
	// END Read the new file into tmp file
	
	// Read rest of the file
	if (new_origin_size >= origin_file->filesize)
	{
		size_t offset = (size_t)F_head + origin_file->filesize;
		printf("Reading %zu bytes from %zu\n", (size_t)F_size - (size_t)(F_head + origin_file->filesize), offset);
		fwrite(F_head + origin_file->filesize, 1,
		       F_size - (entry_point + origin_file->filesize), outfile);
		
	}
	else if (new_origin_size < origin_file->filesize)
	{
	        // Broken.
		fwrite(F_head + origin_file->filesize, 1,
		       (int)F_size - (entry_point + origin_file->filesize), outfile);
	}
	// Rest of file is read! We're done, right?
	printf("%zu - %zu = %zu\n", F_size, entry_point, F_size - entry_point);
	long final_pos = ftell(outfile);
	
	
	// If new file is bigger, we need to update all indexes within file
	fseek(outfile, 0, SEEK_SET);
	inject_update_offsets(outfile, real_filename, new_origin_size,
	                      origin, origin_file, deep_file);
	
	// Start copying over
	F_close(); // Reading from file now. Spare some memory
	fseek(outfile, 0, SEEK_SET);
	FILE* infile = fopen(F_name, "w");
	
	tmpptr = malloc(final_pos + 1);
	fread(tmpptr, 1, final_pos + 1, outfile);
	fclose(outfile);
	fwrite(tmpptr, 1, final_pos, infile);
	free(tmpptr);
	
	fclose(infile);
	exit(0);
}

void
inject_files(unsigned deep,
             char const** in_files,
             size_t in_len,
             struct bp_file* deep_file)
{
	uchar* initial_pos = F_head;
	//////
	struct bp_file* files;
	struct bp_filepack_header header;
	size_t files_len = read_filepack_header(&header, &files);
	read_filenames(files, files_len);
	
	for (int i = 0; i < files_len; ++i)
	{
		header_seek_begin(&header);
		//fseek(FP, files[i].offset, SEEK_CUR); // Go to file
		F_head += files[i].offset;
		
		DEBUGF("Filename: %s - Filesize: %d at offset %d\n",
		       files[i].filename, files[i].filesize, (int)F_head - (int)F);
		
		for (int j = 0; j < in_len; ++j)
		{
			char* real_file = strchr(in_files[j], '/');
			if (!real_file) real_file = in_files[j];
			else
			{
				++real_file; // Skip slash character
				unixdir_to_windir(real_file);
			}
			
			if (strstr(files[i].filename, real_file) != NULL)
			{
				char input = strcmp(files[i].filename, real_file) == 0 ? 'y' : 0;
				while (input != 'y' && input != 'n')
				{
					printf("Is \"%s\" correct? [y/n]: ", files[i].filename);
					input = getchar();
				}
				
				if (input == 'y')
				{
					windir_to_unixdir(real_file);
					inject_to_new_file(in_files[j], real_file, files + i,
					                   deep_file);
					printf("Injected \"%s\" into \"%s\". =^)\n",
					       real_file, deep_file->filename);
				}
			}
		}
		
		if (deep)
			inject_files(0, in_files, in_len, files + i);
	}
	// TODO loop through and free filenames and such
	//free(files);
	//////
	F_head = initial_pos;
}

void
F_close()
{
#ifdef MMAP_MEMCPY
	free(F);
	munmap(F_map, F_size);
#else
	munmap(F, F_size);
#endif
}

int
main(int argc, char** argv)
{
	if (argc <= 2)
	{
		puts(help);
		return EXIT_FAILURE;
	}
	
	/* Tar-like switches */
	for (char* i = argv[1]; *i != '\0'; ++i)
	{
		switch (*i)
		{
		case '-': continue;
		case 'x': opts.x = 1; break;
		case 'd': opts.d = 1; break;
		case 'c': opts.c = 1; break;
		case 'i': opts.i = 1; break;
		default:
			printf("%s\n\nUnrecognized option \"%c\".\n", help, i[0]);
			return EXIT_FAILURE;
		}
	}

///////////////////////////////
//   Extraction
///////////////////////////////	
	if (opts.x)
	{
		int fd = open(argv[2], O_RDONLY);
		
		if (fd == -1)
		{
			perror("open");
			return errno;
		}
		
		struct stat s;
		fstat(fd, &s);
		F_size = s.st_size;
			
		F_head = F = mmap(0, F_size, PROT_READ, MAP_PRIVATE, fd, 0);
#ifdef MMAP_MEMCPY
		uchar* F_map = F;
	
		F = malloc(F_size);
		memcpy(F, F_map, F_size);
		F_head = F;
#endif	
	
		if (!F)
		{
			perror("mmap");
			return errno;
		}
	
		/* First header sometimes contains .BPM's (BeXide Package Metadata?)
		 *  These headers contain more filepack headers... not sure why it's
		 *  like this? */
		 read_files(opts.d);
		 
#ifdef MMAP_MEMCPY
		free(F);
		munmap(F_map, F_size);
#else
		munmap(F, F_size);
#endif
		close(fd);	
		return EXIT_SUCCESS;
	}
///////////////////////////////
//   Injection
///////////////////////////////
	else if (opts.i)
	{
		if (argc == 3)
		{	
			puts(help);
			return EXIT_FAILURE;
		}
		char const* output = argv[2];
		
		int fd = open(output, O_RDONLY);
		
		F_name = output;
		
		if (fd == -1)
		{
			perror("open");
			return errno;
		}
		
		struct stat s;
		fstat(fd, &s);
		F_size = s.st_size;
			
		F_head = F = mmap(0, F_size, PROT_READ, MAP_PRIVATE, fd, 0);
#ifdef MMAP_MEMCPY
		F_map = F;
	
		F = malloc(F_size);
		memcpy(F, F_map, F_size);
		F_head = F;
#endif	
		if (!F)
		{
			perror("mmap");
			return errno;
		}
	
		/* First header sometimes contains .BPM's (BeXide Package Metadata?)
		 *  These headers contain more filepack headers... not sure why it's
		 *  like this? */
		inject_files(opts.d, argv + 3, argc - 3, NULL);
		 
		F_close();
		close(fd);	
		return EXIT_SUCCESS;
	}
///////////////////////////////
//   Creation (BROKEN)
///////////////////////////////
	else if (opts.c)
	{
		if (argc == 3)
		{	
			puts(help);
			return EXIT_FAILURE;
		}
		char const* output = argv[2];
		
		// Ur seein' it :^)
		struct bp_file* files;
		size_t files_len = 0;
		
		//char* rem_slash = strchr(argv[argc-1], '/');
		//if (rem_slash) *rem_slash = '\0';

		/*deep_readdir(strlen(argv[argc-1])+1,
		             output,
		             argv[argc-1],
		             &files,
		             &files_len);*/
		
		create_bp_archive(output, files, files_len);
		
		
		return EXIT_SUCCESS;
	}
	puts(help);
	return EXIT_FAILURE;
}

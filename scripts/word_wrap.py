import argparse
import sys
if hasattr(sys.stdin, "reconfigure"):
    sys.stdin.reconfigure(encoding="utf-8")
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

data = sys.stdin.read()

def load_char_widths(file_path):
    widths = {}
    with open(file_path, 'r') as file:
        for line in file:
            char, width = line.strip().split('=')
            widths[char] = int(width)
    return widths

def modify_string(input_string, max_width, char_widths):
    total_width = 0
    last_space_index = -1
    current_word_start = 0

    i = 0  # Initialize index
    while i < len(input_string):
        char = input_string[i]
        # Get character width, default to 10 if not found
        char_width = char_widths.get(char, 10)
        # Add character width to total
        total_width += char_width

        # Track the last space index
        if char == ' ':
            last_space_index = i

        # Check if the total width exceeds max_width
        if total_width > max_width:
            if last_space_index != -1:
                # Replace last space with "[LR]"
                input_string = input_string[:last_space_index] + '[LR]\n' + input_string[last_space_index + 1:]
            #else:
            #    # If no space is found, split the current word
            #    current_word_start = input_string.rfind(' ', 0, i) + 1  # Start of the current word
            #    current_word = input_string[current_word_start:i + 1]  # Extract the current word
            #    
            #    # Replace the current word with the split version
            #    input_string = (
            #        input_string[:current_word_start] + current_word[:-1] + '-[LR]' + current_word[-1] + input_string[i + 1:]
            #    )

            # Reset total width and last space index
            total_width = 0
            last_space_index = -1

            # Reset current word index for the next iteration
            current_word_start = 0
            
            # Continue processing from the next character after the last change
            continue  # Start the next iteration of the while loop

        i += 1  # Move to the next character

    return input_string  # Return the modified string

# Main execution
if __name__ == "__main__":
    #parser = argparse.ArgumentParser(description='Modify input string based on character widths and maximum width.')
    #parser.add_argument('input_string', type=str, help='The input string to modify.')

    #args = parser.parse_args()
    #input_string = args.input_string  # Get input_string from command line argument
    input_string = data

    max_width = 140  # Set maximum width
    char_widths = load_char_widths('char_widths.txt')  # Load character widths
    result_string = modify_string(input_string, max_width, char_widths)  # Modify the string

    print(result_string, end="")  # Print the modified string

#!/bin/bash

# Function to combine CSV files into main.csv

 csv_files=$(find . -maxdepth 1 -type f -name "*.csv")

# Iterate over each CSV file
    for file in $csv_files; do
    # Change roll number from lower case to upper case using awk
    awk 'BEGIN {FS=OFS=","} {$1 = toupper($1)} 1' "$file" > temp.csv && mv temp.csv "$file"
    done

combine() {
    rm -f main.csv  # Remove existing main.csv

    # Get a list of all CSV files in the directory
    csv_files=(*.csv)
    touch main.csv
    # Create the header row for main.csv
    header="Roll_Number,Name"
    for file in "${csv_files[@]}"; do
    # Add the name of the CSV file to the header row
    # Get the name of the CSV file without the .csv extension
    # Check if the file contains the string "main"
    if [[ "$file" == *"main"* ]]; then
        continue
    fi
    # Add the name of the CSV file to the header row
        header+=",$(basename "$file" .csv)"
    done
    # Add header row to main.csv
    echo "$header" >> main.csv
    # Create an associative array to store the students' data
    declare -A students
    # Iterate over each roll number
    roll_numbers=()
    # Iterate over each file in the list
    for file in "${csv_files[@]}"; do
        # Read the CSV file and add the roll number to the roll_numbers array
        while IFS=',' read -r roll name marks || [ -n "$roll" ] ;  do
        # Check if the roll number is already in the array
            if [[ "$roll" != "Roll_Number" ]]; then  # Skip header row
             roll=$(echo "$roll" )
             # Change the roll number to uppercase and remove the b from the roll number
                roll_numbers+=("$roll")
            fi
        done < "$file"
        # Iterate over each line in the file
    done
    
    
    # Sort and remove duplicates from roll_numbers
    roll_numbers=($(printf '%s\n' "${roll_numbers[@]}" | sort -u))
    # Remove the last element from the array
    unset 'roll_numbers[${#roll_numbers[@]}-1]'
    
    # Create the main.csv file
    # Append header to the main.csv file
    echo "Roll_Number,Name${header#Roll_Number,Name}" > main.csv

for roll in "${roll_numbers[@]}"; do
    # Iterate over each file in the list
    marks=()
    for file in "${csv_files[@]}"; do
        # Check if the roll number is present in the file
        if grep -iq "$roll" "$file" ; then
        # Print the file name
        name=$(grep -i "$roll" "$file" | cut -d "," -f 2)
        # Append the marks to the marks array
        marks+=","$(grep -i "$roll" "$file" | cut -d "," -f 3)
        # Check if the roll number is present in the file
        else
        # Append a blank mark to the marks array
        marks+=",a"
        fi
    done
    # Print the roll number, name, and marks to the main.csv file
    echo "$roll,$name${marks[@]}" >> main.csv
done
}

# Function to upload a new CSV file
upload() {
    if [ -n "$1" ]; then
    # Check if the file exists
        file_path="$1"
        # Check if the file exists
        file_extension="${file_path##*.}"
        # Check if the file extension is csv
        if [ "$file_extension" == "csv" ]; then
            cp "$file_path" .
            # Check if the file is empty
            if [ -s "$file_path" ]; then
                echo "Error: File is empty."
                exit 1
            fi
            # Check if the file is valid
            echo "File $file_path uploaded successfully."
        else
        # If the file extension is not csv, print an error message
            echo "Error: Invalid file extension. Only CSV files are allowed."
        fi
    else
    # If the file path is not provided, print an error message
        echo "Usage: bash submission.sh upload <file_path>"
    fi
}

# Function to add total column in main.csv
total() {
# Check if the Total header exists in main.csv
if grep -q "Total" main.csv; then
# If the Total header exists, print an error message and exit
    echo "Error: 'Total' header already exists in main.csv. Script cannot be executed."
else
# If the Total header does not exist, add it to the end of the file
awk 'BEGIN { FS=","; OFS="," }
#Add the Total header to the end of the file
NR==1  { print $0, "Total" }
# Add the total column to the rest of the rows
 NR>1 { 
    sum=0; for(i=3; i<=NF; i++){
     if ($i != "a") {
         sum += $i 
         }
    } 
    # Print the row with the total column added
    print $0, sum }' main.csv > tmp.csv &&  mv tmp.csv  main.csv

fi
}
# Function to initialize the remote repository
git_init() {
    # Check if the remote directory path is provided as an argument
    # If the remote directory path is provided, initialize the remote repository
    if [ -n "$1" ]; then
    # Create the remote directory if it does not exist
        remote_dir="$1"
        if [ ! -d "$remote_dir" ]; then
        # Create the remote directory
        mkdir -p "$remote_dir"
        echo "Remote repository initialized at $remote_dir"
        else 
        # Reinitialize the remote repository if it already exists
        cd "$remote_dir"
        # Throw a message
        echo "Reinitialized existing Git repository in $1"
        fi
         touch "$remote_dir"/.git_log
    else
        echo "Usage: bash submission.sh git_init <remote_dir_path>"
    fi
}

# Function to commit changes to the remote repository
git_commit(){
# Main script

# Prompt for commit message
read -p "Enter commit message: " message
# Check if commit message is empty
if [ -z "$message" ]; then
    echo "Commit message cannot be empty."
    return
else 

# Create a timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
# Print the timestamp
echo "$timestamp"
# Create a commit ID (random 7-digit hexadecimal string)
commit_id=$(LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 7)
# Print the commit ID
echo "$commit_id"
# Create a directory for the commit
commit_dir=".git/$commit_id"
# Create the commit directory
mkdir -p "$commit_dir"


# Move staged files to the commit directory
cp  * "$commit_dir/"

# Write commit metadata to a file
echo "Commit ID: $commit_id" >> .git/commits.log
echo "Author: $(whoami) <$USER@$(hostname)>" >> .git/commits.log
echo "Date: $timestamp" >> .git/commits.log
echo "Message: $message" >> .git/commits.log

echo "Changes committed."
fi
}

# Function to checkout a commit
git_checkout() {
        if [ -n "$1" ]; then
        # Check if the commit ID is a prefix or a full hash
            commit_id="$1"
            remot_dir="C:\Users\repud\Downloads\Bash Grader"
            if [ "${#commit_id}" -eq 7 ]; then
                # Find the commit hash based on the prefix
                commit_hash=$(grep -E "^$commit_id" .git/commit.log | head -n 1 | cut -d ' ' -f 1)
                # Check if the commit hash was found
                echo "$commit_hash"
                # Copy the files from the commit directory to the current directory
                if [ -n "$commit_hash" ]; then
                    cp -r "$remot_dir"/"$commit_hash"/* .
                    echo "Checked out to commit: $commit_hash"
                else
                    echo "Error: No matching commit found for prefix '$commit_id'."
                fi
            else
            # Copy the files from the commit directory to the current directory
                if [ -d "$remote_dir"/.git/"$commit_id" ]; then
                    cp -r "$remote_dir"/"$commit_id"/* .
                    echo "Checked out to commit: $commit_id"
                    # Update the current commit ID in the .git/HEAD file
                else
                    echo "Error: Invalid commit hash '$commit_id'."
                fi
            fi
        else
        # Display an error message if the number of arguments is not 1
            echo "Usage: bash submission.sh git_checkout [hash_value]"
        fi
}

# Function to display the commit history
git_log() {
    # Check if the commit history file exists
    if [ ! -f ".git/commits.log" ]; then
        # Display the commit history
        echo "No commit history found."
        else 
        # Display the commit history
        cat ".git/commits.log"
    fi
}

# Function to update student marks
update() {
     # Prompt user for student's details and updated marks
    read -p "Enter student's roll number: " roll_number
    read -p "Enter exam name: " exam_name
    read -p "Enter updated marks for $exam_name: " marks
    # Check if roll number and name match in main.csv
    file=$exam_name.csv
    if ! grep -q "$roll_number" "$file"; then
        echo "Roll number not found in $file"
    else
    # Update the marks in the main.csv file
    awk -v roll="$roll_number" -v score="$marks" 'BEGIN { FS=OFS="," }
   {
    if ($1 == roll ) {
        j=j+1;
        $3 = score;
    }
    print;
    }' "$file" > tmp.csv && mv tmp.csv "$file"
    fi

}


# Main script
case "$1" in
#If the user enters the command "combine"
    combine)
        combine
        ;;
# If the user enters the command "upload"
    upload)
        upload "${@:2}"
        ;;
# If the user enters the command "total"
    total)
        total
        ;;
# If the user enters the command "git_init"
    git_init)
        git_init "${@:2}"
        ;;
# If the user enters the command "git_commit"
    git_commit)
        git_commit "${@:2}"
        ;;
# If the user enters the command "git_checkout"
    git_checkout)
        git_checkout "${@:2}"
        ;;
# If the user enters the command "git_log"
    git_log) 
        git_log "${@:2}"
        ;;
# If the user enters the command "update"
    update)
        update
        ;;
    *)
# If the user enters no argument
        echo "Usage: bash submission.sh <command> [arguments]"
        # List of commands
        echo "Commands: combine, upload, total, git_init, git_commit, git_checkout, update."
        ;;
esac
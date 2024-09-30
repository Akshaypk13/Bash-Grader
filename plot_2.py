import csv
import matplotlib.pyplot as plt
import numpy as np

# Get roll numbers from the main.csv file

def get_roll_numbers(csv_file):
    roll_numbers = []

    with open(csv_file, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        
        for row in reader:
            roll_numbers.append(row['Roll_Number'])

    return roll_numbers

# Get roll numbers from the main.csv file
roll_numbers = get_roll_numbers('main.csv')

def get_total_marks(csv_file):
    total_marks = []

    with open(csv_file, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        
        for row in reader:
            # Extracting the total marks from the 'Total' column
            total_marks.append(int(row['Total']))

    return total_marks

# Get total marks from the main.csv file
total_marks = get_total_marks('main.csv')

mean_marks = np.mean(total_marks)
median_marks = np.median(total_marks)
std_deviation = np.std(total_marks)

# Plotting the bar graph
plt.figure(figsize=(10, 6))
plt.bar(roll_numbers, total_marks, color='darkblue')
plt.xlabel('Roll Number')
plt.ylabel('Total Marks')
plt.title('Total Marks of Students')
# Indicate mean, median, and standard deviation on y-axis
plt.axhline(y=mean_marks, color='red', linestyle='--', label=f'Mean: {mean_marks:.2f}')
plt.axhline(y=median_marks, color='green', linestyle='--', label=f'Median: {median_marks}')
plt.axhline(y=mean_marks + std_deviation, color='orange', linestyle='--', label=f'Standard Deviation: {std_deviation:.2f}')


plt.legend()

plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()

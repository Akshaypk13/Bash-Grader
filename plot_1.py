import os
import pandas as pd
import matplotlib.pyplot as plt

# List all files in the current directory
files = os.listdir('.')

# Initialize an empty list to store filenames
csv_filenames = []

# Iterate over each file
for file in files:
    # Check if the file has a .csv extension
    if file.endswith('.csv') and file != 'main.csv':
        csv_filenames.append(file)

# Calculate the number of rows and columns for subplots
num_plots = len(csv_filenames)
num_cols = 2  # Number of columns for subplots
num_rows = (num_plots + 1) // num_cols

fig, axes = plt.subplots(num_rows, num_cols, figsize=(12, 8))

# Flatten the axes if necessary
if num_plots == 1:
    axes = [axes]

# Remove the empty subplot if the number of subplots is odd
if num_plots % 2 != 0:
    fig.delaxes(axes[-1, -1])

# Plot graphs for each CSV file
for i, filename in enumerate(csv_filenames):
    # Calculate subplot index
    row_index = i // num_cols
    col_index = i % num_cols
    
    # Read CSV file into a DataFrame
    df = pd.read_csv(filename)
    
    # Plot the graph on the corresponding subplot
    ax = axes[row_index][col_index]
    ax.plot(df['Name'], df['Marks'], marker='o', color='red', linestyle='-', linewidth=1.5)
    ax.set_title(f"Graph for {filename}")
    ax.set_xlabel("Name")
    ax.set_ylabel("Marks")
    ax.grid(False)  # Remove grid lines
    
     # Calculate mean, median, and standard deviation
    mean = df['Marks'].mean()
    median = df['Marks'].median()
    std_dev = df['Marks'].std()
    
    # Annotate mean, median, and standard deviation on the plot
    ax.axhline(y=mean, color='blue', linestyle='--', label=f'Mean: {mean:.2f}')
    ax.axhline(y=median, color='green', linestyle='--', label=f'Median: {median:.2f}')
    ax.axhline(y=mean + std_dev, color='red', linestyle='--', label=f'Standard Deviation: {std_dev:.2f}')
    
    # Add legend
    ax.legend(loc='upper left')

# Add a title to the figure
fig.suptitle("Plots for each exam", fontsize=16, fontweight='bold')
# Adjust layout
plt.tight_layout()

# Save the plot as a PNG image
plt.savefig("subplots.png")

# Show the plot
plt.show()



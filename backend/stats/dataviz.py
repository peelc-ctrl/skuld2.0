import pandas as pd
import matplotlib.pyplot as plt

# Read in CSV
df = pd.read_csv(r"C:\SKULD\skuld\backend\stats\Dummy_data.csv")
#print(df.columns)
df["date"] = pd.to_datetime(df["date"])
df["points"] = (df["total_weight_lifted"] / df["body_weight"]) * 100
#print(df["points"])
# Progress Graph Over Time For a Specific User and Specific Exercise
# For a certain user to see their progress
# Filter by their username and their workout
user = "john_doe"
exercise_type = "Squat"
user_progress = df[(df["username"] == user) & (df["exercise"] == exercise_type)]
#print(user_progress)


# Plot weight over time
plt.figure(figsize = (12,6))
plt.plot(user_progress["date"], user_progress["weight_lifted"], marker='o')
plt.title(f"{user.title()}'s {exercise_type.title()} Progress Over Time", fontsize = 20, fontweight='bold')
plt.xlabel("Date")
plt.ylabel("Weight (lbs)")
plt.grid(True)
#plt.show() - commented out for demo
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\weightOverTime.png")



# Plot weight over time with user's personal goal
# If we add a personal goal for the user, its included in this graph
personal_goal = 275 # for squat
plt.figure(figsize = (12,6))
plt.plot(user_progress["date"], user_progress["weight_lifted"], marker='o')
# Goal line
plt.axhline(y=personal_goal, color='red', linestyle='--', linewidth=2, label='Personal Goal')
# Text label above the goal line
plt.text(
    user_progress["date"].min(),
    personal_goal - 2,
    "Personal Goal",
    color='red',
    fontsize=12,
    fontweight='bold'
)
plt.title(f"{user.title()}'s {exercise_type.title()} Progress Over Time", fontsize = 20, fontweight='bold')
plt.xlabel("Date")
plt.ylabel("Weight (lbs)")
plt.grid(True)
#plt.show() - commented out for demo
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\personalGoal.png")



# Pie chart plot of a user's exercise distribution
# Count frequency of each exercise
user = "john_doe"
user_data = df[df["username"] == user]
exercise_counts = user_data["exercise"].value_counts().reset_index()
exercise_counts.columns = ["exercise", "frequency"]
# add percentage column
exercise_counts['Percentage'] = exercise_counts['frequency'] / exercise_counts['frequency'].sum() * 100
#print(exercise_counts)
# Plotting
plt.figure(figsize=(8, 8))
plt.pie(exercise_counts['frequency'], labels=exercise_counts["exercise"], autopct='%1.1f%%', startangle=90, colors=plt.cm.Paired.colors,
        wedgeprops={'edgecolor': 'black', 'linewidth':2}, textprops={'fontsize':14, 'fontweight': 'bold'})
# Add title
plt.title(f"{user.title()}'s Exercise Distribution", fontsize=20, weight='bold')
# Display the chart
#plt.show() - commented out for demo
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\exerciseDist.png")




# Creating a progress bar based on user's personal goal
# Filter by their username and their workout -- from earlier
#user = "john_doe"
#exercise_type = "Squat"
#user_progress = df[(df["username"] == user) & (df["exercise"] == exercise_type)]
#personal_goal = 275 # for squat
current_progress = user_progress['weight_lifted'].max()
# Calculate the progress percentage
progress_percentage = (current_progress / personal_goal) * 100
#print(progress_percentage)
# Create the progress bar plot
fig, ax = plt.subplots(figsize=(8, 2))
# Create the bar
ax.barh(0, progress_percentage, color='green', height = 1)
# Add a label in the center of the bar
ax.text(progress_percentage / 2, 0, f'{progress_percentage:.1f}%',
        ha='center', va='center', color='white', fontsize=12, fontweight='bold')
# Add a black border around the whole bar
ax.barh(0, 100, color='none', edgecolor='black', linewidth=5, height=1)
# Set limits and remove axes
ax.set_xlim(0, 100)
ax.set_ylim(-0.5, 0.5)
ax.axis('off')  # Hide the axes
# Add a title
plt.title(f"{user.title()}'s Progress Towards {exercise_type.title()} Personal Goal", fontsize=16, fontweight='bold')
# Adjust the top of the figure to add more space above the title
plt.subplots_adjust(top=0.85)
# Display the plot
# plt.show() - commented out for demo
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\progressBar.png")





# Circular Progress Bar
# Filter by their username and their workout -- from earlier
#user = "john_doe"
#exercise_type = "Squat"
#user_progress = df[(df["username"] == user) & (df["exercise"] == exercise_type)]
#personal_goal = 275 # for squat
current_progress = user_progress['weight_lifted'].max()
# Calculate the progress percentage
progress_percentage = (current_progress / personal_goal) * 100
#print(progress_percentage)
import numpy as np
# Define the angles for the donut chart (start and end)
start_angle = 90  # Start angle for the donut
end_angle = start_angle - (360 * (progress_percentage / 100))  # Progress arc
# Create a figure and axis
fig, ax = plt.subplots(figsize=(6, 6))
# Create the donut plot (circle with a hole in the middle)
# The wedge represents the progress (green)
ax.pie([progress_percentage, 100 - progress_percentage],
       labels=['', ''],
       colors=['green', 'lightgray'],
       startangle=start_angle,
       counterclock=False,
       wedgeprops={'width': 0.6, 'edgecolor': 'black', 'linewidth': 4})
# Add a title and center text showing the progress
ax.text(0, 0, f'{progress_percentage:.1f}%', ha='center', va='center', fontsize=16, fontweight='bold', color='black')
# Add a title
plt.title(f"{exercise_type.title()} Progress: {current_progress} / {personal_goal} lbs", fontsize=16, fontweight='bold')
# Display the plot
# plt.show() - commented out for demo
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\circleProgress.png")




# Bar Chart of a User's Personal Records per exercise category
# Get the highest weight lifted for each exercise
user_prs = user_data.groupby('exercise')['weight_lifted'].max().reset_index()
# Plot bar chart
plt.figure(figsize=(8, 6))
bars = plt.bar(user_prs['exercise'], user_prs['weight_lifted'], color='skyblue', edgecolor='black')
# Add text labels above bars
for bar in bars:
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 5,
             f"{bar.get_height()} lbs", ha='center', fontsize=12, fontweight='bold')
plt.title(f"{user}'s Personal Records", fontsize=16, fontweight='bold')
plt.ylabel("Weight (lbs)")
plt.xlabel("Exercise")
plt.ylim(0, user_prs['weight_lifted'].max() + 50)
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
# plt.show()
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\personalRecords.png")




# All Friend User PR Visualization
# Filter for a specific exercise
exercise = "Deadlift"
exercise_data = df[df['exercise'] == exercise]
# Get each user's max PR for that exercise
maxPR = exercise_data.groupby('username')['weight_lifted'].max().reset_index()
leaderboard = maxPR.sort_values(by='weight_lifted', ascending=False)
# Plot vertical bar chart
plt.figure(figsize=(10, 6))
bars = plt.bar(maxPR['username'], maxPR['weight_lifted'], color='lightgreen', edgecolor='black')
# Add values above bars
for bar in bars:
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
             f"{bar.get_height()} lbs", ha='center', fontsize=12, fontweight='bold')
plt.title(f"{exercise} Personal Records", fontsize=16, fontweight='bold')
plt.ylabel("Max Weight Lifted (lbs)")
plt.xlabel("User")
plt.xticks(rotation=45, ha='right')
plt.gca().invert_xaxis()  # Put the highest at the top
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
# plt.show() - Friends PR
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\FriendPR.png")




# Leadership Point System Bar Chart
# Define the week you're interested in
# For example: Week starting April 1st to April 7th, 2025
start_date = "2025-04-01"
end_date = "2025-04-07"
# Filter for that week
weekly_data = df[(df["date"] >= start_date) & (df["date"] <= end_date)]
# Group by username and sum the points
weekly_points = weekly_data.groupby("username")["points"].sum().reset_index()
weekly_points = weekly_points.sort_values(by="points", ascending=False)
# Plot the bar chart
plt.figure(figsize=(10, 6))
bars = plt.bar(weekly_points["username"], weekly_points["points"], color='lightgreen', edgecolor='black')
# Add text above bars
for bar in bars:
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
             f"{int(bar.get_height())} pts", ha='center', fontsize=12, fontweight='bold')
plt.title("Total Points by User (Week of April 1–7, 2025)", fontsize=16, fontweight='bold')
plt.xlabel("User")
plt.ylabel("Total Points")
plt.xticks(rotation=45, ha='right')
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
# plt.show() - Leadership Points
plt.savefig(r"C:\SKULD\skuld\backend\post_images\charts\leaderboardPoints.png")

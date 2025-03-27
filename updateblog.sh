#!/bin/bash

# Set variables for Obsidian to Hugo copy
SOURCE_PATH="/Users/killerkidbo/Documents/Obsidian Vault/posts"
DESTINATION_PATH="/Users/killerkidbo/Documents/felixblog/content/posts"

# Set Github repo
MYREPO="git@github.com:heyhuynhgiabuu/felixblog.git"

# Set error handling
set -e

# Check for required commands
for cmd in git hugo; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd is not installed or not in PATH."
        exit 1
    fi
done

# Check for Python command
if command -v python &> /dev/null; then
    PYTHON_CMD="python"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
else
    echo "Python is not installed or not in PATH."
    exit 1
fi

# Step 1: Check if Git is initialized, and initialize if necessary
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git remote add origin $MYREPO
else
    echo "Git repository already initialized."
    if ! git remote | grep -q "origin"; then
        echo "Adding remote origin..."
        git remote add origin $MYREPO
    fi
fi

# Step 2: Sync posts from Obsidian to Hugo content folder
echo "Syncing posts from Obsidian..."
if [ ! -d "$SOURCE_PATH" ]; then
    echo "Source path does not exist: $SOURCE_PATH"
    exit 1
fi

if [ ! -d "$DESTINATION_PATH" ]; then
    echo "Destination path does not exist: $DESTINATION_PATH"
    exit 1
fi

# Use rsync to mirror the directories
rsync -av --delete "$SOURCE_PATH/" "$DESTINATION_PATH/"

# Step 3: Process Markdown files with Python script to handle image links
echo "Processing image links in Markdown files..."
if [ ! -f "images.py" ]; then
    echo "Python script images.py not found."
    exit 1
fi

# Execute the Python script
$PYTHON_CMD images.py

# Step 4: Add changes to Git
echo "Staging changes for Git..."
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to stage."
else
    git add .
fi

# Step 5: Commit changes with a dynamic message
COMMIT_MESSAGE="New Blog Post on $(date '+%Y-%m-%d %H:%M:%S')"
if [ -z "$(git diff --cached --name-only)" ]; then
    echo "No changes to commit."
else
    echo "Committing changes..."
    git commit -m "$COMMIT_MESSAGE"
fi

# Step 6: Push all changes to the main branch
echo "Deploying to GitHub..."
git push origin main

echo "All done! Site synced, processed, committed, and pushed to GitHub."
echo "Cloudflare Pages will automatically deploy your site."

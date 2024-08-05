#!/bin/bash

# Check if the notebook name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <notebook-name>"
  exit 1
fi

NOTEBOOK=$1
BASENAME=$(basename "$NOTEBOOK" .ipynb)
DATE=$(echo "$BASENAME" | cut -d'-' -f1-3)
TITLE=$(echo "$BASENAME" | cut -d'-' -f4-)
POST_NAME="${DATE}-${TITLE}.md"
ASSETS_DIR="/assets/${BASENAME}_files"

# Step 1: Convert the Jupyter Notebook to Markdown
jupyter nbconvert --to markdown "$NOTEBOOK"

# Step 2: Move the converted Markdown file to the _posts directory
mv "${BASENAME}.md" "../_posts/${POST_NAME}"

# Step 3: Remove the existing assets directory if it exists and move the new one
if [ -d "../assets/${BASENAME}_files" ]; then
  rm -rf "../assets/${BASENAME}_files"
fi
mv "${BASENAME}_files" "../assets/"

# Step 4: Add front matter to the Markdown file
FRONT_MATTER="---
layout: post
title: \"${TITLE//-/ }\"
date: ${DATE}
---"

# Create a temporary file with the front matter and the content of the Markdown file
echo -e "${FRONT_MATTER}\n\n$(cat "../_posts/${POST_NAME}")" > "../_posts/${POST_NAME}.tmp"

# Replace the original Markdown file with the temporary file
mv "../_posts/${POST_NAME}.tmp" "../_posts/${POST_NAME}"

# Step 5: Update the links in the Markdown file
sed -i "s|${BASENAME}_files|${ASSETS_DIR}|g" "../_posts/${POST_NAME}"

echo "Notebook ${NOTEBOOK} has been converted and moved to ../_posts/${POST_NAME}"
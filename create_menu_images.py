#!/usr/bin/env python3
"""
Script to create placeholder menu images for the CluckCare app.
This creates simple colored rectangles as placeholders for each menu item.
"""

import os
from PIL import Image, ImageDraw, ImageFont
import textwrap

# Create the assets/images/menu directory if it doesn't exist
os.makedirs("assets/images/menu", exist_ok=True)

# Menu items from the CSV data
menu_items = [
    # Starters
    ("chicken_wings", "Chicken Wings", "#FF6B6B"),
    ("hummus_chicken", "Hummus with Chicken Pieces", "#4ECDC4"),
    ("hummus_beef", "Hummus with Roasted Beef Pieces", "#45B7D1"),
    ("chicken_strips", "Chicken Strips", "#96CEB4"),
    ("chicken_shank", "Chicken Shank", "#FFEAA7"),
    ("chicken_balls", "Chicken Balls", "#DDA0DD"),
    ("spring_roll", "Spring Roll (Chicken)", "#98D8C8"),
    ("chicken_liver", "Chicken Liver", "#F7DC6F"),
    
    # Side Dishes
    ("rice", "Rice", "#85C1E9"),
    ("french_fries", "French Fries", "#F8C471"),
    ("sweet_potato", "Fried Sweet Potato", "#82E0AA"),
    ("rice_plain", "Rice (Plain)", "#D7BDE2"),
    ("steamed_vegetables", "Steamed Vegetables with Chicken", "#A9DFBF"),
    ("potato_wedges", "Wood Roasted Potato Wedges", "#F9E79F"),
    
    # Sandwiches
    ("chicken_sandwich", "Wood Roasted Chicken Sandwich", "#BB8FCE"),
    ("chicken_strips_sandwich", "Wood Roasted Chicken Strips Sandwich", "#85C1E9"),
    ("chicken_balls_sandwich", "Grilled Chicken Balls Sandwich", "#F7DC6F"),
    ("chicken_thigh_sandwich", "Wood Roasted Chicken Thigh Sandwich", "#82E0AA"),
    ("meat_balls_sandwich", "Grilled Meat Balls Sandwich", "#DDA0DD"),
    ("beef_rosto_sandwich", "Wood Roasted Beef Rosto Sandwich (Hot)", "#F8C471"),
    
    # Sweets
    ("apple_pie", "Apple Pie", "#F1948A"),
    ("cheese_cake", "Cheese Cake", "#85C1E9"),
    ("fruit_salad", "Fresh Fruit Salad", "#82E0AA"),
    
    # Main Course
    ("smoked_brisket", "Smoked Brisket", "#D7BDE2"),
    ("chicken_whole", "Wood Roasted Chicken (Whole)", "#F9E79F"),
    ("chicken_half", "Wood Roasted Chicken (Half)", "#A9DFBF"),
    ("chicken_breast", "Wood Roasted Chicken Breast", "#BB8FCE"),
    ("chicken_leg", "Wood Roasted Chicken Leg", "#85C1E9"),
    ("chicken_balls_main", "Chicken Balls", "#F7DC6F"),
    ("chicken_thigh", "Boneless Chicken Thigh", "#82E0AA"),
    ("lamb_ribs", "Wood Roasted Lamb Ribs", "#DDA0DD"),
    ("meat_balls", "Grilled Meat Balls", "#F8C471"),
    ("stuffed_chicken", "Stuffed Chicken Breast", "#F1948A"),
    ("rosto_beef", "Wood Roasted Rosto Beef", "#85C1E9"),
    
    # Soups
    ("lentil_soup", "Lentil Soup with Chicken", "#82E0AA"),
    ("wheat_soup", "Smoked Wheat Soup with Chicken", "#D7BDE2"),
    ("noodles_soup", "Wood Roasted Chicken Noodles Soup", "#F9E79F"),
    ("chicken_soup", "Wood Roasted Chicken Soup", "#A9DFBF"),
]

def create_menu_image(filename, title, color):
    """Create a placeholder image for a menu item."""
    # Image dimensions
    width, height = 300, 200
    
    # Create image with background color
    image = Image.new('RGB', (width, height), color)
    draw = ImageDraw.Draw(image)
    
    # Try to use a default font, fallback to basic if not available
    try:
        font = ImageFont.truetype("arial.ttf", 20)
        small_font = ImageFont.truetype("arial.ttf", 14)
    except:
        font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Add title text
    text_lines = textwrap.wrap(title, width=20)
    y_offset = height // 2 - (len(text_lines) * 25) // 2
    
    for line in text_lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        text_width = bbox[2] - bbox[0]
        x = (width - text_width) // 2
        draw.text((x, y_offset), line, fill='white', font=font)
        y_offset += 25
    
    # Add "CluckCare" branding
    draw.text((10, height - 25), "CluckCare", fill='white', font=small_font)
    
    # Save the image
    image.save(f"assets/images/menu/{filename}.png")
    print(f"Created: {filename}.png")

# Create images for all menu items
for filename, title, color in menu_items:
    create_menu_image(filename, title, color)

print(f"\n✅ Created {len(menu_items)} menu images in assets/images/menu/")
print("You can now replace these placeholder images with actual food photos!")























@echo off
echo Renaming menu images to safe names for Flutter...

REM Create a simple directory for renamed images
mkdir assets\images\menu\renamed 2>nul

REM Copy and rename images to safe names
copy "assets\images\menu\Menu\Starters\Starter_Chicken Wings.png" "assets\images\menu\renamed\chicken_wings.png"
copy "assets\images\menu\Menu\Starters\Starter_HUmmus with chicken.png" "assets\images\menu\renamed\hummus_chicken.png"
copy "assets\images\menu\Menu\Starters\Starter_Hummus with Roasted Beef Pieces.png" "assets\images\menu\renamed\hummus_beef.png"
copy "assets\images\menu\Menu\Starters\Starter_Chicken Shank.png" "assets\images\menu\renamed\chicken_shank.png"
copy "assets\images\menu\Menu\Starters\Starter_Chicken Balls.png" "assets\images\menu\renamed\chicken_balls_starter.png"
copy "assets\images\menu\Menu\Starters\Starter_Chicken Spring Roll.png" "assets\images\menu\renamed\spring_roll.png"
copy "assets\images\menu\Menu\Starters\Starter_Chicken Liver.png" "assets\images\menu\renamed\chicken_liver.png"

copy "assets\images\menu\Menu\Side dish\SideDish_Rice.png" "assets\images\menu\renamed\rice.png"
copy "assets\images\menu\Menu\Side dish\SideDish_French Fries.png" "assets\images\menu\renamed\french_fries.png"
copy "assets\images\menu\Menu\Side dish\SideDish_Fried Sweet Potato.png" "assets\images\menu\renamed\sweet_potato.png"
copy "assets\images\menu\Menu\Side dish\SideDish_Rice (Plain).png" "assets\images\menu\renamed\rice_plain.png"
copy "assets\images\menu\Menu\Side dish\SideDish_Steamed Vegetables with Chicken.png" "assets\images\menu\renamed\steamed_vegetables.png"
copy "assets\images\menu\Menu\Side dish\SideDish_Wood Roasted Potato Wedges.png" "assets\images\menu\renamed\potato_wedges.png"

copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Wood Roasted Chicken.png" "assets\images\menu\renamed\chicken_sandwich.png"
copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Wood Roasted Chicken Strips.png" "assets\images\menu\renamed\chicken_strips_sandwich.png"
copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Grilled Chicken Balls.png" "assets\images\menu\renamed\chicken_balls_sandwich.png"
copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Wood Roasted Chicken Thigh.png" "assets\images\menu\renamed\chicken_thigh_sandwich.png"
copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Grilled Meat Balls.png" "assets\images\menu\renamed\meat_balls_sandwich.png"
copy "assets\images\menu\Menu\Sandwitches\Sandwiches_Wood Roasted Beef Rosto Sandwich (Hot).png" "assets\images\menu\renamed\beef_rosto_sandwich.png"

copy "assets\images\menu\Menu\Sweets\Sweets_Apple Pie.png" "assets\images\menu\renamed\apple_pie.png"
copy "assets\images\menu\Menu\Sweets\Sweets_Cheese Cake.png" "assets\images\menu\renamed\cheese_cake.png"
copy "assets\images\menu\Menu\Sweets\Sweets_Fresh Fruit Salad.png" "assets\images\menu\renamed\fruit_salad.png"

copy "assets\images\menu\Menu\Main Course\Main Course_Smoked Brisket.png" "assets\images\menu\renamed\smoked_brisket.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Chicken (Whole).png" "assets\images\menu\renamed\chicken_whole.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Chicken (Half).png" "assets\images\menu\renamed\chicken_half.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Chicken Breast.png" "assets\images\menu\renamed\chicken_breast.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Chicken Leg.png" "assets\images\menu\renamed\chicken_leg.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Chicken Balls.png" "assets\images\menu\renamed\chicken_balls_main.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Boneless Chicken Thigh.png" "assets\images\menu\renamed\chicken_thigh.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Lamb Ribs.png" "assets\images\menu\renamed\lamb_ribs.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Grilled Meat Balls.png" "assets\images\menu\renamed\meat_balls.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Stuffed Chicken Breast.png" "assets\images\menu\renamed\stuffed_chicken.png"
copy "assets\images\menu\Menu\Main Course\Main Course_Wood Roasted Rosto Beef.png" "assets\images\menu\renamed\rosto_beef.png"

copy "assets\images\menu\Menu\Soups\Soup_Lentil Soup with Chicken.png" "assets\images\menu\renamed\lentil_soup.png"
copy "assets\images\menu\Menu\Soups\Soup_Smoked Wheat Soup with Chicken.png" "assets\images\menu\renamed\wheat_soup.png"
copy "assets\images\menu\Menu\Soups\Soup_Wood Roasted Chicken Noodles Soup.png" "assets\images\menu\renamed\noodles_soup.png"
copy "assets\images\menu\Menu\Soups\Soup_Wood Roasted Chicken Soup.png" "assets\images\menu\renamed\chicken_soup.png"

echo Images renamed successfully!
echo You can now use the renamed images in the assets/images/menu/renamed/ folder
pause























// ignore_for_file: constant_identifier_names, non_constant_identifier_names

//~ Server Config:
// POST https://textstore.ai/wp-json/jwt-auth/v1/token
// BODY { "username": "",  "password": "" }
import 'package:flutter/foundation.dart';

//! This file should be .env

// POST https://textstore.ai/wp-json/jwt-auth/v1/token
// BODY { "username": "",  "password": "" }
// Might need to update expiration to Never
// const adminJwt =
//     'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3d3dy50ZXh0c3RvcmUuYWkiLCJpYXQiOjE2ODU2MzAyMjUsIm5iZiI6MTY4NTYzMDIyNSwiZXhwIjoxNjg2MjM1MDI1LCJkYXRhIjp7InVzZXIiOnsiaWQiOiIxIn19fQ.l4TWSgHiHnDgL13u-24McMYgP1u-rhOrOiYAG0p_RjY';

// My Working Wordpress php request:  https://gist.github.com/idan054/a02143ad92cf65ce090f8dfe697c6419
const appCategoryId = 27; // only subCategories of it will appear
const baseUrl = 'https://www.textstore.ai/wp-json';
// const baseUrl = 'https://wordpress-665866-3576746.cloudwaysapps.com/wp-json';

// DEFAULT POSTS:
// - Google 1685
// - Name 1672
// - Short 1476
// - Long 1402
const promptsCategoryIds = [28, 29, 30, 31];
const textStoreUid = 1; // Admin user
var appConfig_userJwt = ''; // Set on main() main.dart

//! This JWT Must be secure!
var appConfig_userMaker_Jwt =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODYyNTIzNzUsImVtYWlsIjoidXNlck1ha2VyQHVzZXJNYWtlci5jb20iLCJpZCI6Ijk1Iiwic2l0ZSI6Imh0dHBzOlwvXC93d3cudGV4dHN0b3JlLmFpIiwidXNlcm5hbWUiOiJ1c2VyTWFrZXIifQ.gMyR1ROS4dp8t7beefZLJmGAjS4Z143LhDJcKwnSSTs'; // Set on main() main.dart

const appConfig_hideDefault = true || !kDebugMode;
const textStoreAi = 'TextStore';
const appConfig_highlightSelection = true;
const appConfig_horizontalSummery = true;
const appConfig_collapseMode = true;

// const appConfig_fastHomeScreen = true && kDebugMode;
const appConfig_fastHomeScreen = false;

const longDescSample =
    '''Nike Air Max 90 is a classic sneaker that has been around since the early 90s. It is one of the most iconic sneakers in the history of sportswear and is loved by people all over the world. The Nike Air Max 90 is a shoe that was created by Tinker Hatfield, who was inspired by the idea of visible air. The sneaker has a unique design and is known for its comfort and style. 
One of the most significant features of the Nike Air Max 90 is the visible Air Sole unit that is present in the midsole. This unit was a groundbreaking piece of technology when it was first introduced, and it has since become a defining feature of the Air Max line. The Air Sole unit provides cushioning and support, making the sneaker comfortable to wear for extended periods. The design of the sneaker has also been refined over the years, with updates to the materials and construction methods used in its production.
The Nike Air Max 90 is a versatile sneaker that can be matched with a range of outfits. It is suitable for casual wear, but it can also be worn for athletic activities. The sneaker is available in a variety of colors and styles, making it easy to find a pair that fits your style. There are also several special editions of the Air Max 90, which are released periodically to mark significant events or collaborations with other brands or designers.
One of the most well-known special editions of the Nike Air Max 90 is the "Infrared" colorway. This colorway includes a black and white base with red accents on the Air Sole unit and other details on the sneaker. This colorway is highly sought after by sneaker enthusiasts and is considered a classic in the sneaker community. Other popular special editions include those designed in collaboration with artists, musicians, and other brands.
The Nike Air Max 90 has been worn by several prominent athletes, including Michael Jordan, LeBron James, and Kobe Bryant. These athletes have helped to popularize the sneaker and have contributed to its iconic status. The sneaker has also been featured in several movies and TV shows, further cementing its place in popular culture.
The Nike Air Max 90 is not just a stylish sneaker; it is also a durable and reliable shoe. The materials used in its construction are of high quality, ensuring that the sneaker can withstand regular wear and tear. The sneaker also features excellent traction, making it suitable for a range of surfaces and activities.
In conclusion, the Nike Air Max 90 is a classic sneaker that has stood the test of time. It is a comfortable and stylish shoe that can be worn for a range of activities. Its iconic design and visible Air Sole unit have made it a favorite among sneaker enthusiasts and athletes alike. Whether you are looking for a casual sneaker or a shoe to wear during athletic activities, the Nike Air Max 90 is an excellent choice. With its durability, versatility, and timeless design, this sneaker is sure to remain a favorite for years to come.
null ''';

const appVersion = 'Version 2.0.1 GPT4';

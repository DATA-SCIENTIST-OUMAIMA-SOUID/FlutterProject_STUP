// ignore_for_file: constant_identifier_names

const BOOKREQUEST = 'TableBook';

const COD = 'CODSettings';
const CONTACT_US = 'ContactUs';
const COUPON = 'coupons';
const Currency = 'currencies';
const Deliverycharge = 6;
const FavouriteItem = "favorite_item";
const FavouriteRestaurant = "favorite_restaurant";
const GlobalURL = "https://foodie.siswebapp.com/";
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const MENU_ITEM = 'menu_items';
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const Order_Rating = 'foods_review';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_PLACED = 'Order Placed';

const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDERREQUEST = 'Order';
const ORDERS = 'restaurant_orders';
const ORDERS_TABLE = 'booked_table';
const PAYMENT_SERVER_URL = 'https://murmuring-caverns-94283.herokuapp.com/';
const PRODUCTS = 'vendor_products';
const REFERRAL = 'referral';
const REPORTS = 'reports';
const REVIEW_ATTRIBUTES = "review_attributes";

const SECOND_MILLIS = 1000;

const SERVER_KEY =
    'AAAAQBUQI6c:APA91bH8psxznjF63YiAhtZxfhSzui5YmG_Y6V7CTc9F50q9uezlt5xpd0HQ7QH0Cw9bQBvmbE9AMSpO0lwttKeJyQTiGE8tR5XhHcMuJWnNeqO7md2j0v83fyCaU_MuUCxVsFY4RVUe';
const Setting = 'settings';
const STORY = 'story';
const StripeSetting = 'stripeSettings';
const USER_ROLE_CUSTOMER = 'customer';
const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_VENDOR = 'vendor';
const USERS = 'users';

const VENDOR_ATTRIBUTES = "vendor_attributes";
const VENDORS = 'vendors';
const VENDORS_CATEGORIES = 'vendor_categories';

const Wallet = "wallet";

String appVersion = '';

String currName = "";
int decimal = 2;
String GOOGLE_API_KEY = '';

/// GetX Template Generator - fb.com/htngu.99
///

String home = 'Home';
bool isDineInEnable = false;
bool isRight = false;

String placeholderImage =
    'https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/images%2Fplace_holder.png?alt=media&token=f391844e-0f04-44ed-bf37-e6a1c7d91020';

String referralAmount = "0.0";

String symbol = '\$';

double getDoubleVal(dynamic input) {
  if (input == null) {
    return 0.1;
  }

  if (input is int) {
    return double.parse(input.toString());
  }

  if (input is double) {
    return input;
  }
  return 0.1;
}

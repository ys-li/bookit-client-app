class BKLocale{
  static String MENU_SETTINGS = "Settings";
  static String MENU_ABOUT = "About";
  static String MENU_TERMS = "Terms";
  static String BAR_HOME = "Home";
  static String BAR_BOOKLIST = "Booklist";
  static String BAR_BUY = "Buy";
  static String BAR_SELL = "Sell";
  static String BAR_CHAT = "Chat";
  static String TITLE_BUYLIST = "Buy List";
  static String TITLE_SELLLIST = "Sell List";
  static String BUY_BOOKLIST_HEADER = "Your Buy List";
  static String SELL_BOOKLIST_HEADER = "Your Sell List";
  static String BOOKLIST_CHANGED = "Booklist changes saved.";
  static String BOOKLIST_CHANGED_FAILED = "Oops, something went wrong, please modify your booklist again.";
  static String UNSAVED_CHANGES = "Unsaved changes!";
  static String UNSAVED_CHANGES_CONTENT = "You have unsaved changes. Do you want to discard them?";
  static String DISCARD = "DISCARD";
  static String CANCEL = "CANCEL";
  static String DONE = "DONE";
  static String CANT_BUY_SELL_SAME_BOOK = "You can't buy and sell the same book!";
  static String WARNING = "Warning";
  static String WARNING_CHANGE_FORM = "Users can only select one form to buy from. Your booklist will be reset. Continue?";
  static String CONTINUE = "CONTINUE";
  static String SECONDARY1 = "Secondary 1";
  static String SECONDARY2 = "Secondary 2";
  static String SECONDARY3 = "Secondary 3";
  static String SECONDARY4 = "Secondary 4";
  static String SECONDARY5 = "Secondary 5";
  static String SECONDARY6 = "Secondary 6";
  static String SECONDARY_SELECTOR_CAPTION = "Books for";
  static String NO_PACKAGES = "There are no package satifying your filter, \nplease adjust the filter and try again!";
  static String SORT_BY = "Sort By";
  static String PRICE = "Price";
  static String SELLERS = "Sellers";
  static String BOOKS = "Books";
  static String NUMBER_OF_SELLERS = "Number of Seller(s)";
  static String MIN_BOOKS_MATCHED = "Min. Book(s) Matched";
  static String SCORE = "Score";
  static String SEARCH_RESULT = "Search (!no results)";
  static String AVAILABLE = "Available";
  static String DEALING = "In progress";
  static String FINISHED = "Completed";
  static String BOOKS_MATCHED = "Books Matched";
  static String STATUS = "Status";
  static String DETAILS = "Details";
  static String CONFIRM_PACKAGE = "Take this package!";
  static String BOOK_LISTING = "This Book Listing";
  static String BOOK_DETAILS = "Book description";
  static String FULL_NAME = "Full name";
  static String PUBLISHER = "Publisher";
  static String ISBN = "ISBN";
  static String AUTHOR = "Author";
  static String FOR_SECONDARY = "For Secondary";
  static String AVG_PRICE = "Average Price";
  static String REMARKS = "Remarks";
  static String NO_REMARKS = "No special remark for this listing.";
  static String UPDATING_PACKAGES = "Finding best packages for you...";
  static String CONFIRM_PACKAGE_CONTENT = "Are you sure to take this package? Once you confirm, the books will be taken off the system and you can no longer take another package until you finished / exited the trade!";
  static String CONFIRM = "Confirm";
  static String SOMETHING_WRONG = "Something went wrong!";
  static String ALREADY_IN_PACKAGE = "You have already been matched with a package!\nPlease visit the package to continue the trade.";
  static String CONFIRMED_PACKAGE = "Package successfully confirmed! Data synchronised with your school.";
  static String LOADING = "Loading...";
  static String CHAT_NOW = "Chat now";
  static String EXPIRED = "Expired";
  static String USER_MATCHED = "Users matched (unsettled)";
  static String EARNINGS = "Earning";
  static String WELCOME_SIGNIN = "Welcome to Bookit! Please sign in to continue.";
  static String LOGIN_FAILED = "Log in failed, please try again.";
  static String LOGIN_WITH_GOOGLE = "Login with Google";
  static String SIGN_OUT = "Sign out";
  static String CHAT_BUYING_CAPTION = "You are buying !no books.";
  static String CHAT_SELLING_CAPTION = "You are selling !no books.";
  static String CHAT_NO_DEALING_CAPTION = "You have no active dealings with";
  static String DEAL_BUTTON = "Complete Deal";
  static String CANCEL_TRADE_BUTTON = "Cancel Trade";
  static String CONFIRM_DEAL = "Confirm trade?";
  static String CONFIRM_DEAL_CONTENT = "The trade will be considered completed once you confirmed it.";
  static String CANCEL_DEAL = "Forgo trade?";
  static String CANCEL_DEAL_CONTENT = "The trade will be cancelled and you will not be rematched until all your trade has been completed/cancelled.";
  static String OPERATION_FAILED = "Operation failed, please try again.";
  static String TRADE_COMPLETED = "Trade completed! Thank you for using Bookit.";
  static String TRADE_CANCELLED = "Trade cancelled.";
  static String SERVER_DOWN = "Server is currently under maintenance. We will be back soon!";
  static String HAVE_ACTIVE_PACKAGE = "YOUR ACTIVE PACKAGE";
  static String RECONNECT_SERVER = "Retry connection";
  static String NEW_BOOKS = "New listings";
  static String TRANSACTION_HISTORY = "Transaction History";
  static String COMPLETED_BUY_USER = "Bought !no books from !user.";
  static String COMPLETED_SELL_USER = "Sold !no books to !user.";
  static String TRADE_CANCELLED_USER = "Cancelled !no-book trade with !user.";
  static String BUY_SELL_FORM_HELPER_TEXT = "You can buy books for one form only, but sell books from multiple forms.";
  static String SCHOOL = "School";
  static String PRICE_OF_BOOK_SLIDER = "Your selling price:";
  static String SENDING_PHOTO = "Sending photo...";
  static String PACKAGE_COMPLETED = "Package Completed!";

  static void setLanguage(bool ch) => ch ? _setToChinese() : _setToEnglish();

  static void _setToChinese(){

  }

  static void _setToEnglish(){

  }

}
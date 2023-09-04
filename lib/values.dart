import 'package:http/http.dart';
import 'dart:convert';
import 'models/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class Values extends ChangeNotifier {
  Values(Box box) {
    setting = box;
    cityId = box.get("city_id") ?? 0;
    languageId = box.get("language_id") ?? 0;
    languageCode = box.get("languageCode") ?? "ru";

    if (languageId == 0) {
      List<Languages> languagesList = [
        Languages(name: "", code: "en", languageId: 1, code2: ""),
        Languages(name: "", code: "de", languageId: 7, code2: ""),
        Languages(name: "", code: "es", languageId: 5, code2: ""),
        Languages(name: "", code: "fr", languageId: 6, code2: ""),
        Languages(name: "", code: "it", languageId: 12, code2: ""),
        Languages(name: "", code: "pl", languageId: 11, code2: ""),
        Languages(name: "", code: "pt", languageId: 8, code2: ""),
        Languages(name: "", code: "tr", languageId: 10, code2: ""),
        Languages(name: "", code: "uk", languageId: 4, code2: "")
      ];

      for (var l in languagesList) {
        if (l.code == Platform.localeName) {
          languageId = l.languageId!;
          languageCode = l.code!;
        }
      }

      if (languageId == 0) {
        languageId = 3;
      }
    }

    notifyListeners();
  }

  Map<String, dynamic> productVariant = {};
  List<Map<dynamic, dynamic>> historyPush = [];
  Box? setting;
  Account? account;
  Map<dynamic, dynamic>? appleUser;
  Categories? category;
  Filters? sorts;
  List<Filters>? filterGroups;
  Filters? filters;
  List<Categories>? children;
  List<Categories>? childrenMenu;
  List<Categories>? categories;
  Product? product;
  List<Categories>? popular;
  List<ProductModules>? productModules;
  List<Banners>? banners;
  Future<Data>? api;
  DateTime? toDate;
  int languageId = 0,
      cityId = 0,
      page = 1,
      accountId = 0,
      countOpenFilter = 0,
      productLimit = 30,
      categoryId = 50,
      menuCategoryId = 0,
      menuChildCategoryId = 0,
      productId = 0,
      productQuantity = 1,
      qwUse = 0,
      variant4 = 0,
      commentTree = 300,
      giftTree = 300,
      chaiSet = 0,
      activeImage = 0,
      orderId = 0;
  String languageCode = "ru",
      currentRoute = "/",
      coupon = "",
      countryCode = "",
      currencyCode = "UAH",
      sessionId = "",
      date = "",
      initialUrl = "",
      selectTime = "",
      selectPayment = "",
      dateSelected = "",
      dateSelectedText = "",
      chaiP = "",
      checkoutTel = "";
  double chai = 0.0,
      webViewHeight = 400;
  bool searchVisible = false,
      popupVisible = false,
      searchFieldActive = false,
      desAnim = false,
      openFilters = false,
      splash = false,
      isHistory = false,
      isLoading = false,
      fieldIsLoading = false,
      fieldRegisterIsLoading = false,
      loadMore = false,
      isLoad = false,
      sortLoaded = false,
      sortResetLoaded = false,
      filterLoaded = false,
      resetLoaded = false,
      submitLoaded = false,
      errorVisible = false,
      successVisible = false,
      vazDelete = false,
      couponOpen = false,
      notAdr = false,
      agree = false,
      buyVisible = false;
  var selectedFilters = <String>[];
  var products = <Products>[];
  List<int>? _wishlist;
  List<int>? _viewed;
  var cart = <Cart>[];
  var time = <Time>[];
  var totals = <Totals>[];
  var productRelated = <Products>[];
  var carouselThumbController = CarouselController();
  var carouselController = CarouselController();
  dynamic productIndexVariant;

  dynamic get wishlist {
    return _wishlist ??= getWishlist();
  }

  dynamic get viewed {
    return _viewed ??= getViewed();
  }

  getProductRelated() async {
    await api!.then((value) => productRelated = value.product!.products!);
    return productRelated;
  }

  String getCartQuantity() {
    var qw = 0;

    if (cart.isNotEmpty) {
      for (var element in cart) {
        qw += element.quantity!;
      }
    }

    return qw == 0 ? "" : qw.toString();
  }

  List<int> getWishlist() {
    return setting!.get('wishlist') ?? <int>[];
  }

  List<int> getViewed() {
    return setting!.get('viewed') ?? <int>[];
  }

  setSelectedFilters(List<String> newValue) async {
    selectedFilters = newValue;

    if (selectedFilters.isNotEmpty) {
      await api!.then((value) => selectedFilter(value));
    }

    notifyListeners();
  }

  void selectedFilter(Data value) {
    if (value.categories!.isNotEmpty) {
      for (var item in value.categories!) {
        for (var filters in item.filters!) {
          for (var filter in filters.filter!) {
            filter.active = false;

            for (var s in selectedFilters) {
              if (filter.val == s) {
                filter.active = true;
                break;
              }
            }
          }
        }
      }

      api = f(value);
    }

    notifyListeners();
  }

  Future<Data> f(Data newValue) async {
    return newValue;
  }

  void setCityId(int newValue) {
    setting!.put('city_id', newValue);
    cityId = newValue;
    notifyListeners();
  }

  String getCountFilters() {
    var sel = selectedFilters;

    final tr = LocaleKeys.textFilter.tr();

    if (sel.isNotEmpty) {
      final length = sel.length;
      return "$tr ( $length )";
    } else {
      return tr;
    }
  }

  resetHistory() {
    historyPush = [];
    notifyListeners();
  }

  setHistory(Map<dynamic, dynamic> value) {
    historyPush.add(value);
    notifyListeners();
  }

  setCountOpenFilter(int value) {
    countOpenFilter = value;
    notifyListeners();
  }

  deleteLastHistory() async {
    var route = currentRoute;

    if (historyPush.isNotEmpty) {
      route = historyPush.last["route"]!;
      currentRoute = route;
      await api!.whenComplete(() {
        historyPush.last["api"]!;
      });

      historyPush.removeAt(historyPush.length-1);
      isHistory = true;
    } else {
      historyPush = [];
    }

    await setData(route);
    notifyListeners();
  }

  deleteIndexHistory() async {
    if (historyPush.isNotEmpty) {
      historyPush.removeAt(historyPush.length-2);
    }

    notifyListeners();
  }

  void setBuyVisible(bool newValue) {
    buyVisible = newValue;
    notifyListeners();
  }

  void setOpenFilters(bool newValue) {
    openFilters = newValue;
    notifyListeners();
  }

  void setActiveImage(int newValue) {
    activeImage = newValue;
    notifyListeners();
  }

  void setPayment(String newValue) {
    selectPayment = newValue;
    notifyListeners();
  }

  void setInitialUrl(String newValue) {
    initialUrl = newValue;
    notifyListeners();
  }

  void setWebViewHeight(double newValue) {
    webViewHeight = newValue;
    notifyListeners();
  }

  void setSplash(bool newValue) {
    splash = newValue;
    notifyListeners();
  }

  void setOrderId(int newValue) {
    setting!.put('order_id', newValue);
    orderId = newValue;
    notifyListeners();
  }

  void setPopupVisible(bool newValue) {
    popupVisible = newValue;
    notifyListeners();
  }

  void setAppleUser(String? id, String name, String lastname, String email) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id!;
    data["name"] = name;
    data["lastname"] = lastname;
    data["email"] = email;
    setting!.put('apple_user', data);
    appleUser = data;
    notifyListeners();
  }

  Map<dynamic, dynamic>? getAppleUser() {
    return setting!.get('apple_user');
  }

  void setNotAdr(bool newValue) {
    notAdr = newValue;
    notifyListeners();
  }

  void setSortLoaded(bool newValue) {
    sortLoaded = newValue;
    notifyListeners();
  }

  void setSortResetLoaded(bool newValue) {
    sortResetLoaded = newValue;
    notifyListeners();
  }

  void setCheckoutTel(String newValue) {
    checkoutTel = newValue;
    notifyListeners();
  }

  void setAgree(bool newValue) {
    agree = newValue;
    notifyListeners();
  }

  void setChaiSet(int newValue) {
    chaiSet = newValue;
    notifyListeners();
  }

  void setChai(double newValue) {
    chai = newValue;
    notifyListeners();
  }

  void setChaiP(String newValue) {
    chaiP = newValue;
    notifyListeners();
  }

  void setCommentTree(int newValue) {
    commentTree = newValue;
    notifyListeners();
  }

  void setGiftTree(int newValue) {
    giftTree = newValue;
    notifyListeners();
  }

  void setCouponOpen(bool newValue) {
    couponOpen = newValue;
    notifyListeners();
  }

  void setCoupon(String newValue) {
    coupon = newValue;
    notifyListeners();
  }

  void setAccountId(int newValue) {
    setting!.put('account_id', newValue);
    accountId = newValue;
    notifyListeners();
  }

  void setLoadMore(bool newValue) {
    loadMore = newValue;
    notifyListeners();
  }

  void setDesAnim(bool newValue) {
    desAnim = newValue;
    notifyListeners();
  }

  void setSelectTime(String newValue) {
    selectTime = newValue;
    notifyListeners();
  }

  void setSelectDate(String newValue) {
    dateSelected = newValue;
    notifyListeners();
  }

  void setToDate(DateTime newValue) {
    toDate = newValue;
    notifyListeners();
  }

  void setSelectDateText(String newValue) {
    dateSelectedText = newValue;
    notifyListeners();
  }

  void setErrorVisible(bool newValue) {
    errorVisible = newValue;
    notifyListeners();
  }

  void setSuccessVisible(bool newValue) {
    successVisible = newValue;
    notifyListeners();
  }

  void setFilterLoaded(bool newValue) {
    filterLoaded = newValue;
    notifyListeners();
  }

  void setResetLoaded(bool newValue) {
    resetLoaded = newValue;
    notifyListeners();
  }

  void setProducts(bool reset) {
    if (reset) {
      products = <Products>[];
    }

    filterLoaded = false;
    resetLoaded = false;
    sortLoaded = false;
    sortResetLoaded = false;

    products.addAll(category!.products!.map((element) {
      return element;
    }));

    notifyListeners();
  }

  void setSearchFieldActive(bool newValue) {
    searchFieldActive = newValue;
    notifyListeners();
  }

  void setFieldIsLoading(bool newValue) {
    fieldIsLoading = newValue;
    notifyListeners();
  }

  void setFieldRegisterIsLoading(bool newValue) {
    fieldRegisterIsLoading = newValue;
    notifyListeners();
  }

  void setProductId(int newValue) {
    productId = newValue;
    setting!.put('product_id', newValue);
    viewed.remove(newValue);
    viewed.add(newValue);
    setQwUse(0);
    setVariant4(0);
    setViewed(viewed);
    notifyListeners();
  }

  void setRoute(String newValue) {
    currentRoute = newValue;
    setting!.put('route', newValue);
    notifyListeners();
  }

  void setPage() {
    page++;
    loadMore = true;
    notifyListeners();
  }

  void setCategoryId(int newValue) {
    setting!.put('category_id', newValue);
    categoryId = newValue;
    page = 1;
    selectedFilters = <String>[];
    products = <Products>[];
    notifyListeners();
  }

  void setMenuCategoryId(int newValue) {
    menuCategoryId = newValue;
    notifyListeners();
  }

  void setMenuChildCategoryId(int newValue) {
    menuChildCategoryId = newValue;
    notifyListeners();
  }

  void setWishlist(List<int> newValue) async {
    _wishlist = newValue;
    await setting!.put('wishlist', newValue);

    await updateWishlist();

    if (currentRoute == "account") {
      setData("account");
    }

    notifyListeners();
  }

  void setCart(List<Cart> newValue) {
    var carts = <Cart>[];

    for (var e in newValue) {
      carts.add(e);
    }

    cart = carts;
    notifyListeners();
  }

  void setTotals(List<Totals> newValue) {
    var total = <Totals>[];

    for (var e in newValue) {
      total.add(e);
    }

    totals = total;
    notifyListeners();
  }

  void setTime(List<Time> newValue) {
    var times = <Time>[];

    for (var e in newValue) {
      times.add(e);
    }

    time = times;
    notifyListeners();
  }

  void setDate(String newValue) {
    date = newValue;
    notifyListeners();
  }

  void setProductRelated(List<Products> newValue) {
    var products = <Products>[];

    for (var e in newValue) {
      products.add(e);
    }

    productRelated = products;
    notifyListeners();
  }

  void setViewed(List<int> newValue) {
    _viewed = newValue;
    setting!.put('viewed', newValue);
    notifyListeners();
  }

  void setLanguageId(int newValue) {
    languageId = newValue;
    setting!.put('language_id', newValue);
    notifyListeners();
  }

  void setSessionId(dynamic newValue) {
    sessionId = newValue;
    setting!.put('session_id', newValue);
    notifyListeners();
  }

  void setLanguageCode(String newValue) {
    languageCode = newValue;
    notifyListeners();
  }

  void updateSearchVisible(bool value) {
    searchVisible = value;
    notifyListeners();
  }

  void setSubmitLoaded(bool value) {
    submitLoaded = value;
    notifyListeners();
  }

  void setProductIndex(dynamic value) {
    productIndexVariant = value;
    notifyListeners();
  }

  void setQwUse(int value) {
    qwUse = value;
    notifyListeners();
  }

  setFilters(Filters? value) {
    filters = value!;
    notifyListeners();
  }

  void resetFilters() {
    Filters? value;
    filters = value;
    notifyListeners();
  }

  void setVariant4(int value) {
    variant4 = value;
    notifyListeners();
  }

  void setProductQuantity(String value) {
    var qw = productQuantity;

    if (value == "+") {
      qw++;
    } else {
      qw--;

      if (qw <= 0) qw = 1;
    }

    productQuantity = qw;

    notifyListeners();
  }

  void setProductVariant(Map<String, dynamic> value) {
    productVariant = value;
    notifyListeners();
  }

  void setChildren(List<Categories> categories) {
    children = categories;
    notifyListeners();
  }

  void setMenuChildren(List<Categories> categories) {
    childrenMenu = categories;
    notifyListeners();
  }

  setData(String route) async {
    var body = {};

    setPopupVisible(false);

    cityId = setting!.get('city_id') ?? 0;
    languageId = setting!.get("language_id") ?? 3;

    if (route != "category") {
      categoryId = 50;
      setting!.put('category_id', 50);
    } else {
      categoryId = setting!.get('category_id') ?? 50;
    }

    submitLoaded = false;
    appleUser = setting!.get('apple_user') ?? {};
    accountId = setting!.get('account_id') ?? 0;
    productLimit = 30;
    coupon = setting!.get('coupon') ?? "";
    currencyCode = setting!.get('currency') ?? "UAH";
    _wishlist = setting!.get('wishlist');
    _viewed = setting!.get('viewed');
    sessionId = setting!.get('session_id') ?? "";
    productId = setting!.get('product_id') ?? 0;
    searchVisible = false;
    orderId = setting!.get('order_id') ?? 0;
    notAdr = false;
    time = <Time>[];
    chai = 0.0;
    chaiP = "";

    if (page > 1 && route != 'category') {
      page = 1;
    }

    if (route == 'product' && productId == 0) {
      route = "/";
    } else if (route == 'payment' && orderId == 0) {
      route = "/";
    }

    setting!.put('route', route);

    if (cityId == 0) {
      route = "city";

      body = {
        'type': '1',
        'method': 'regions'
      };
    }
    else {
      if (route == '/') {
        body = {
          'type': '1',
          'language_id': languageId,
          'account_id': setting!.get('account_id') ?? 0,
          'coupon': setting!.get('coupon') ?? "",
          'category_id': 50,
          'city_id': cityId,
          'limit': setting!.get('productLimit') ?? 30,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,regions,categories,languages,products,popular,product_modules,banners,home_slider,account'
        };
      }
      else if (route == 'product') {
        body = {
          'type': '1',
          'language_id': languageId,
          'account_id': setting!.get('account_id') ?? 0,
          'coupon': setting!.get('coupon') ?? "",
          'product_id': productId,
          'category_id': categoryId,
          'city_id': cityId,
          'limit': setting!.get('productLimit') ?? 30,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'viewed': viewed != null ? viewed.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,regions,categories,languages,products,product,account'
        };
      }
      else if (route == 'category') {
        body = {
          'type': '1',
          'language_id': languageId,
          'account_id': setting!.get('account_id') ?? 0,
          'coupon': setting!.get('coupon') ?? "",
          'category_id': categoryId,
          'city_id': cityId,
          'limit': setting!.get('productLimit') ?? 30,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,categories,languages,products,category,account'
        };

        if (page > 1) {
          body.addAll({"page": page});
        }

        if (selectedFilters.isNotEmpty) {
          var filters = <String>[];

          for (var i in selectedFilters) {
            if (i.contains("-DESC") || i.contains("-ASC")) {
              var sort = i.split("-");
              body.addAll({"sort": sort[0], "order": sort[1]});
            } else {
              filters.add(i);
            }
          }

          if (filters.isNotEmpty) {
            body.addAll({"filter": filters.join(",")});
          }
        }
      }
      else if (route == 'forgotten') {
        body = {
          'type': '1',
          'language_id': languageId,
          'coupon': setting!.get('coupon') ?? "",
          'city_id': cityId,
          'category_id': categoryId,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,categories,languages,products,account'
        };
      }
      else if (route == 'account') {
        body = {
          'type': '1',
          'language_id': languageId,
          'coupon': setting!.get('coupon') ?? "",
          'city_id': cityId,
          'account_id': setting!.get('account_id'),
          'category_id': categoryId,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,categories,languages,products,account'
        };
      }
      else if (route == 'checkout') {
        dateSelected = DateTime.now().toString();

        body = {
          'type': '1',
          'language_id': languageId,
          'coupon': setting!.get('coupon') ?? "",
          'city_id': cityId,
          'information_id': 13,
          'ios': Platform.isIOS,
          'date': dateSelected,
          'account_id': accountId,
          'category_id': categoryId,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,time,categories,languages,products,account,informations,account'
        };

        getCountry();
      }
      else if (route == 'payment') {
        body = {
          'type': '1',
          'language_id': languageId,
          'coupon': setting!.get('coupon') ?? "",
          'city_id': cityId,
          'order_id': orderId,
          'account_id': accountId,
          'category_id': categoryId,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'cart,categories,languages,products,order,account'
        };
      }
    }

    if (!isHistory) {
      api = getApi(body, route);
      await api!.then((value) => save());
    } else {
      isHistory = false;
    }
print(historyPush);
    return api;
  }

  void save() {
    notifyListeners();
  }

  String getProductPrice(dynamic index) {
    var price = "";

    if (productVariant["$index"] != null) {
      price = productVariant["$index"]['price'];
    }

    return price;
  }

  void setProductPrice(dynamic index, dynamic value, dynamic quantity) {
    if (productVariant["$index"] != null && value != null) {
      productVariant["$index"]["price"] = jsonDecode(value).toString();
      if (quantity != 0) productVariant["$index"]["sost"][0]["qw"] = quantity;
      save();
    }
  }

  String getProductSku(dynamic index) {
    var sku = "";

    if (productVariant["$index"] != null) {
      sku = productVariant["$index"]['sku'];
    }

    return sku;
  }

  List<Sost> getVariant(dynamic index) {
    var variants = <Sost>[];

    if (productVariant["$index"] != null) {
      for (var i in productVariant["$index"]['sost']) {
        variants.add(Sost.fromJson(i));
      }
    }

    return variants;
  }

  String getProductSpecial(dynamic index) {
    var special = "";

    if (productVariant["$index"] != null && productVariant["$index"]['special'] != "false") {
      special = productVariant["$index"]['special'];
    }

    return special;
  }

  String getProductPercent(dynamic index) {
    var percent = "";

    if (productVariant["$index"] != null && productVariant["$index"]['percent'] != "") {
      percent = productVariant["$index"]['percent'];
    }

    return percent;
  }

  Future<Data> getApi(body, route) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body)
    ).catchError((error) {
      return error;
    });

    currentRoute = route;

    body["route"] = route;

    if (response.statusCode == 200) {
      final Data data = Data.fromJson(jsonDecode(response.body));

      if (cityId > 0 && (currentRoute == "category" && page == 1 || currentRoute != "category")) {
        body["api"] = data;
        setHistory(body);
      }

      if (data.cart != null && data.cart!.isNotEmpty) {
        setCart(data.cart!);
      } else {
        cart = <Cart>[];
      }

      if (currentRoute == "product") {
        if (data.product != null && data.product!.products!.isNotEmpty) {
          productRelated = data.product!.products!;
        }

        productIndexVariant = 1;

        if (data.product != null && data.product!.variants != null) {
          productVariant = data.product!.variants!;

          if (productVariant.length >= 2) {
            productIndexVariant = 2;
          }
        }

        if (data.product != null && data.product!.qws!.isNotEmpty) {
          for (var e in data.product!.qws!) {
            if (e.use == 1) {
              productIndexVariant = e.index;
            }
          }

          if (productIndexVariant == 0) {
            productIndexVariant = data.product!.qws![0].index!;
          }
        }
      }

      if (data.totals != null) setTotals(data.totals!);

      if (data.setting!.currency != "") {
        currencyCode = data.setting!.currency!;
        setting!.put('currency', currencyCode);
      }

      if (data.account != null) {
        account = data.account!;
      }

      if (data.category != null) {
        category = data.category!;

        if (data.category != null && data.category!.children != null) setChildren(data.category!.children!);

        if (data.category != null && data.category!.filters != null) {
          var groups = <Filters>[];

          for (var i in data.category!.filters!) {
            if (0 == i.filterGroupId!) {
              sorts = i;
            } else {
              groups.add(i);
            }
          }

          filterGroups = groups;
        }
      }

      if (data.categories != null) {
        categories = data.categories!;

        if (menuCategoryId > 0 && categories!.isNotEmpty) {
          childrenMenu = [];

          for (var i in categories!) {
            if (currentRoute == "category" && categoryId == i.parentId && i.children != null && i.children!.isNotEmpty && (children == null || (children != null && children!.isNotEmpty))) {
              setChildren(i.children!);
            }

            if (i.categoryId == menuCategoryId && i.children != null && i.children!.isNotEmpty) {
              for (var e in i.children!) {
                childrenMenu!.add(e);
              }
            }
          }
        }
      }

      if (data.popular != null) {
        popular = data.popular!;
      }

      if (data.product != null) {
        product = data.product!;
      }

      if (data.productModules != null) {
        productModules = data.productModules!;
      }

      if (data.banners != null) {
        banners = data.banners!;
      }

      if (data.time != null) {
        time = data.time!;
      }

      if (data.order != null) {
        if (data.order!.monoPay != null && data.order!.monoPay != "") {
          selectPayment = "mono";
        } else {
          selectPayment = "stripe";
        }
      }

      return data;
    } else {
      throw Exception("Error response");
    }
  }

  Future jsonResponse(body) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body)
    ).catchError((error) {
      return error;
    });

    return (response.statusCode == 200) ? response.body : null;
  }

  Future getTime() async {
    var response = jsonResponse({
      "type": 1,
      "method": "time",
      "date": dateSelected,
      "city_id": cityId,
      "account_id": accountId,
      "language_id": languageId,
      "session_id": sessionId
    });

    var times = <Time>[];

    await response.then((value) {
      setSubmitLoaded(false);
      value = json.decode(value);

      if (value != null && value != []) {
        for (var e in value!["time"]) {
          times.add(Time.fromJson(e));
        }

        setTime(times);
      }
    });
  }

  void getCountry() async {
    final response = await post(
        Uri.parse("http://ip-api.com/json"),
        headers: {
          'Content-Type': 'application/json',
        }
    ).catchError((error) {
      return error;
    });

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json["countryCode"] != null) {
        countryCode = json["countryCode"];
      }
    }
  }

  Future updateWishlist() async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'type': '1',
          'language_id': languageId,
          'account_id': setting!.get('account_id') ?? 0,
          'city_id': cityId,
          'limit': setting!.get('productLimit') ?? 30,
          'currency': setting!.get('currency') ?? "UAH",
          'wishlist': wishlist != null ? wishlist.join(",") : "",
          'session_id': setting!.get('session_id') ?? "",
          'method': 'account'
        })
    ).catchError((error) {
      return error;
    });

    if (response.statusCode == 200) {
      final data = response.body;
      final jsonData = json.decode(data);
      var wishlists = <Products>[];

      if (jsonData != null && jsonData.isNotEmpty && jsonData!["account"] != null) {
        for (var i in jsonData!["account"]!["wishlist"]) {
          final Products product = Products.fromJson(i);
          wishlists.add(product);
        }

        if (account == null) {
          account = Account(customerId: 0,
              customerGroupId: 0,
              email: "",
              firstname: "",
              telephone: "",
              customer: "",
              wishlist: wishlists,
              orders: [],
              reward: 0);
        } else {
          account?.wishlist = wishlists;
        }
      } else {
        account?.wishlist = [];
      }

      save();

      return data;
    } else {
      return null;
    }
  }

  Future cartAdd(int productId, int qw, dynamic index, int vazId, qws, variant4) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "type": 2,
          "method": "cart",
          "index": index ?? 1,
          "quantity": qw,
          "qw": qws.toString(),
          "sost4": variant4.toString(),
          "city_id": cityId,
          "vaza_id": vazId,
          "language_id": languageId,
          "account_id": accountId,
          "session_id": sessionId,
          "currency": currencyCode,
          "coupon": coupon,
          "product_id": productId
        })
    ).catchError((error) {
      return error;
    });

    setSubmitLoaded(false);

    if (response.statusCode == 200) {
      final data = response.body;
      final jsonCart = json.decode(data);
      var carts = <Cart>[];
      var total = <Totals>[];

      if (jsonCart != null && jsonCart.isNotEmpty) {
        if (sessionId == "") {
          setSessionId(jsonCart!["cart"][0]["session_id"]);
        }

        for (var i in jsonCart!["totals"]) {
          total.add(Totals.fromJson(i));
        }

        for (var i in jsonCart!["cart"]) {
          final Cart cart = Cart.fromJson(i);
          carts.add(cart);

          if (currentRoute == "product" && productRelated.isNotEmpty) {
            for (var element in productRelated) {
              if (element.productId == cart.productId) {
                element.cartId = cart.cartId;
                element.cartQuantity = cart.quantity;
                break;
              }
            }
          }
        }

        totals = total;
        cart = carts;
        save();
      }

      return data;
    } else {
      return null;
    }
  }

  Future cartUpdate(int cartId, int qw) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "type": 2,
          "method": "cart",
          "quantity": qw,
          "city_id": cityId,
          "cart_id": cartId,
          "language_id": languageId,
          "account_id": accountId,
          "session_id": sessionId,
          "currency": currencyCode,
          "coupon": coupon,
          "product_id": productId
        })
    ).catchError((error) {
      return error;
    });

    setSubmitLoaded(false);

    if (response.statusCode == 200) {
      final data = response.body;
      final jsonCart = json.decode(data);
      var carts = <Cart>[];
      var total = <Totals>[];

      if (jsonCart != null && jsonCart.isNotEmpty) {
        for (var i in jsonCart!["totals"]) {
          total.add(Totals.fromJson(i));
        }

        for (var i in jsonCart!["cart"]) {
          final Cart cart = Cart.fromJson(i);
          carts.add(cart);

          if (currentRoute == "product" && productRelated.isNotEmpty) {
            for (var element in productRelated) {
              if (element.productId == cart.productId) {
                element.cartId = cart.cartId;
                element.cartQuantity = cart.quantity;
                break;
              }
            }
          }
        }

        cart = carts;
        totals = total;
        save();
      }

      return data;
    } else {
      return null;
    }
  }

  Future cartRemove(int cartId, int vazId, int productId) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "type": 1,
          "method": "cart",
          "cart_delete": 1,
          "city_id": cityId,
          "cart_id": cartId,
          "language_id": languageId,
          "account_id": accountId,
          "session_id": sessionId,
          "currency": currencyCode,
          "coupon": coupon,
          "vaza_id": vazId
        })
    ).catchError((error) {
      return error;
    });

    setSubmitLoaded(false);

    if (response.statusCode == 200) {
      final data = response.body;
      final jsonCart = json.decode(data);
      var carts = <Cart>[];
      var total = <Totals>[];

      if (jsonCart != null && jsonCart.isNotEmpty) {
        if (jsonCart!["totals"] != null) {
          for (var i in jsonCart!["totals"]) {
            total.add(Totals.fromJson(i));
          }
        }

        for (var i in jsonCart!["cart"]) {
          final Cart cart = Cart.fromJson(i);
          carts.add(cart);
        }

        if (currentRoute == "product" && productRelated.isNotEmpty) {
          for (var element in productRelated) {
            if (element.productId == productId) {
              element.cartId = 0;
              element.cartQuantity = 0;
            }
          }
        }

        if (productId == vazId) {
          vazDelete = true;
        }

        cart = carts;
        totals = total;
        save();
      }

      return data;
    } else {
      return null;
    }
  }
}
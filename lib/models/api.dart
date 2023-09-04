class Data {
  Setting? setting;
  List<Cart>? cart;
  List<Totals>? totals;
  List<Time>? time;
  List<Categories>? categories;
  Categories? category;
  List<Categories>? popular;
  List<Languages>? languages;
  List<Currencies>? currencies;
  List<Regions>? regions;
  List<Wishlist>? wishlist;
  List<Products>? products;
  List<ProductModules>? productModules;
  List<Banners>? banners;
  List<Banners>? homeSlider;
  List<Information>? information;
  Account? account;
  Product? product;
  Order? order;
  String? phoneRegionCode;
  String? price;

  Data(
      {this.setting,
        this.cart,
        this.totals,
        this.time,
        this.categories,
        this.category,
        this.popular,
        this.languages,
        this.currencies,
        this.regions,
        this.wishlist,
        this.products,
        this.productModules,
        this.banners,
        this.homeSlider,
        this.information,
        this.account,
        this.product,
        this.order,
        this.phoneRegionCode,
        this.price});

  Data.fromJson(Map<String, dynamic> json) {
    account = json['account'] != null ? Account.fromJson(json['account']) : null;
    setting = json['setting'] != null ? Setting.fromJson(json['setting']) : null;
    phoneRegionCode = json['phone_region_code'];
    price = json['price'];
    product = json['product'] != null && json['product'] != [] ? Product.fromJson(json['product']) : null;
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    category = json['category'] != null ? Categories.fromJson(json['category']) : null;
    if (json['product_modules'] != null) {
      productModules = <ProductModules>[];
      json['product_modules'].forEach((v) {
        productModules!.add(ProductModules.fromJson(v));
      });
    }
    if (json['banners'] != null) {
      banners = <Banners>[];
      json['banners'].forEach((v) {
        banners!.add(Banners.fromJson(v));
      });
    }
    if (json['home_slider'] != null) {
      homeSlider = <Banners>[];
      json['home_slider'].forEach((v) {
        homeSlider!.add(Banners.fromJson(v));
      });
    }
    if (json['informations'] != null) {
      information = <Information>[];
      json['informations'].forEach((v) {
        information!.add(Information.fromJson(v));
      });
    }
    if (json['time'] != null) {
      time = <Time>[];
      json['time'].forEach((v) {
        time!.add(Time.fromJson(v));
      });
    }
    if (json['cart'] != null) {
      cart = <Cart>[];
      json['cart'].forEach((v) {
        cart!.add(Cart.fromJson(v));
      });
    }
    if (json['totals'] != null) {
      totals = <Totals>[];
      json['totals'].forEach((v) {
        totals!.add(Totals.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['popular'] != null) {
      popular = <Categories>[];
      json['popular'].forEach((v) {
        popular!.add(Categories.fromJson(v));
      });
    }
    if (json['languages'] != null) {
      languages = <Languages>[];
      json['languages'].forEach((v) {
        languages!.add(Languages.fromJson(v));
      });
    }
    if (json['currencies'] != null) {
      currencies = <Currencies>[];
      json['currencies'].forEach((v) {
        currencies!.add(Currencies.fromJson(v));
      });
    }
    if (json['regions'] != null) {
      regions = <Regions>[];
      json['regions'].forEach((v) {
        regions!.add(Regions.fromJson(v));
      });
    }
    if (json['wishlist'] != null) {
      wishlist = <Wishlist>[];
      json['wishlist'].forEach((v) {
        wishlist!.add(Wishlist.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (account != null) {
      data['account'] = account!.toJson();
    }
    data['phone_region_code'] = phoneRegionCode;
    data['price'] = price;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (order != null) {
      data['order'] = order!.toJson();
    }
    if (setting != null) {
      data['setting'] = setting!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (productModules != null) {
      data['product_modules'] =
          productModules!.map((v) => v.toJson()).toList();
    }
    if (banners != null) {
      data['banners'] =
          banners!.map((v) => v.toJson()).toList();
    }
    if (homeSlider != null) {
      data['home_slider'] =
          homeSlider!.map((v) => v.toJson()).toList();
    }
    if (information != null) {
      data['informations'] =
          information!.map((v) => v.toJson()).toList();
    }
    if (time != null) {
      data['time'] =
          time!.map((v) => v.toJson()).toList();
    }
    if (cart != null) {
      data['cart'] = cart!.map((v) => v.toJson()).toList();
    }
    if (totals != null) {
      data['totals'] = totals!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (popular != null) {
      data['popular'] = popular!.map((v) => v.toJson()).toList();
    }
    if (languages != null) {
      data['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    if (currencies != null) {
      data['currencies'] = currencies!.map((v) => v.toJson()).toList();
    }
    if (regions != null) {
      data['regions'] = regions!.map((v) => v.toJson()).toList();
    }
    if (wishlist != null) {
      data['wishlist'] = wishlist!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Account {
  late int? customerId;
  late int? customerGroupId;
  late String? email;
  late String? firstname;
  late String? telephone;
  late String? customer;
  late List<Products>? wishlist;
  late List<Orders>? orders;
  late int? reward = 0;

  Account(
      {required this.customerId,
        required this.customerGroupId,
        required this.email,
        required this.firstname,
        required this.telephone,
        required this.customer,
        required this.wishlist,
        required this.orders,
        required this.reward});

  Account.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerGroupId = json['customer_group_id'];
    email = json['email'];
    firstname = json['firstname'];
    telephone = json['telephone'];
    customer = json['customer'];
    if (json['wishlist'] != null) {
      wishlist = <Products>[];
      json['wishlist'].forEach((v) {
        wishlist!.add(Products.fromJson(v));
      });
    }
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    reward = json['reward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    data['customer_group_id'] = customerGroupId;
    data['email'] = email;
    data['firstname'] = firstname;
    data['telephone'] = telephone;
    data['customer'] = customer;
    if (wishlist != null) {
      data['wishlist'] = wishlist!.map((v) => v.toJson()).toList();
    }
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    data['reward'] = reward;
    return data;
  }
}

class Orders {
  late int? orderId;
  late String? oid;
  late String? date;
  late String? shippingFirstname;
  late String? shippingAddress1;
  late String? vrem;
  late String? telz;
  late String? total;
  late String? status;
  late List<Products>? products;
  late List<Totals>? totals;
  late bool? active;

  Orders(
      {required this.orderId,
        required this.oid,
        required this.date,
        required this.shippingFirstname,
        required this.shippingAddress1,
        required this.vrem,
        required this.telz,
        required this.total,
        required this.status,
        required this.products,
        required this.totals,
        required this.active});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    oid = json['oid'];
    date = json['date'];
    shippingFirstname = json['shipping_firstname'];
    shippingAddress1 = json['shipping_address_1'];
    vrem = json['vrem'];
    telz = json['telz'];
    total = json['total'];
    status = json['status'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    if (json['totals'] != null) {
      totals = <Totals>[];
      json['totals'].forEach((v) {
        totals!.add(Totals.fromJson(v));
      });
    }
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['oid'] = oid;
    data['date'] = date;
    data['shipping_firstname'] = shippingFirstname;
    data['shipping_address_1'] = shippingAddress1;
    data['vrem'] = vrem;
    data['telz'] = telz;
    data['total'] = total;
    data['status'] = status;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (totals != null) {
      data['totals'] = totals!.map((v) => v.toJson()).toList();
    }
    data['active'] = active;
    return data;
  }
}

class ProductModules {
  late String? title;
  late String? width;
  late String? height;
  late int? categoryId;
  late List<Products>? products;

  ProductModules({required this.title, required this.width, required this.height, required this.categoryId, required this.products});

  ProductModules.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    width = json['width'];
    categoryId = json['category_id'];
    height = json['height'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['width'] = width;
    data['category_id'] = categoryId;
    data['height'] = height;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Information {
  late int? id;
  late String? title;
  late String? description;

  Information({required this.id, required this.title, required this.description});

  Information.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

class Banners {
  late String? title;
  late String? image;
  late int? categoryId;

  Banners({required this.title, required this.image, required this.categoryId});

  Banners.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    image = json['image'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['image'] = image;
    data['category_id'] = categoryId;
    return data;
  }
}

class Setting {
  late String? currency;
  late String? language;
  late String? phone;
  late String? viber;
  late String? whatsapp;
  late String? telegram;
  late String? fbMessenger;
  late String? instagram;
  late String? facebook;
  late String? geoCity;
  late String? seoUrl;
  late bool? couponStatus;
  String? description = "";

  Setting(
      {required this.currency,
        required this.language,
        required this.phone,
        required this.viber,
        required this.whatsapp,
        required this.telegram,
        required this.fbMessenger,
        required this.instagram,
        required this.facebook,
        required this.geoCity,
        required this.seoUrl,
        required this.couponStatus,
        required this.description});

  Setting.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    language = json['language'];
    phone = json['phone'];
    viber = json['viber'];
    whatsapp = json['whatsapp'];
    telegram = json['telegram'];
    fbMessenger = json['fb_messenger'];
    instagram = json['instagram'];
    facebook = json['facebook'];
    geoCity = json['geoCity'];
    seoUrl = json['seourl'];
    couponStatus = json['coupon_status'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['language'] = language;
    data['phone'] = phone;
    data['viber'] = viber;
    data['whatsapp'] = whatsapp;
    data['telegram'] = telegram;
    data['fb_messenger'] = fbMessenger;
    data['instagram'] = instagram;
    data['facebook'] = facebook;
    data['geoCity'] = geoCity;
    data['seourl'] = seoUrl;
    data['coupon_status'] = couponStatus;
    data['description'] = description;
    return data;
  }
}

class Time {
  late String? time;
  late int? first;

  Time(
      {required this.time,
        required this.first});

  Time.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    first = json['utro'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['utro'] = first;
    return data;
  }
}

class StripePay {
  late String? paymentIntent;
  late String? ephemeralKey;
  late String? customer;
  late String? publishableKey;

  StripePay(
      {required this.paymentIntent,
        required this.ephemeralKey,
        required this.customer,
        required this.publishableKey});

  StripePay.fromJson(Map<String, dynamic> json) {
    paymentIntent = json['paymentIntent'];
    ephemeralKey = json['ephemeralKey'];
    customer = json['customer'];
    publishableKey = json['publishableKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentIntent'] = paymentIntent;
    data['ephemeralKey'] = ephemeralKey;
    data['customer'] = customer;
    data['publishableKey'] = publishableKey;
    return data;
  }
}

class Order {
  late int? orderId;
  late String? oid;
  late String? shippingFirstname;
  late String? telZ;
  late String? date;
  late String? time;
  late String? monoPay;
  late String? shippingAddress;
  late StripePay? stripe;
  late bool? wayForPay;
  late bool? active;
  late List<Product>? products;
  late List<Totals>? totals;

  Order(
      {required this.orderId,
        required this.oid,
        required this.shippingFirstname,
        required this.telZ,
        required this.date,
        required this.time,
        required this.monoPay,
        required this.shippingAddress,
        required this.stripe,
        required this.wayForPay,
        required this.active,
        required this.products,
        required this.totals});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    oid = json['oid'];
    shippingFirstname = json['shipping_firstname'];
    telZ = json['telz'];
    date = json['date'];
    time = json['vrem'];
    monoPay = json['mono_pay'];
    shippingAddress = json['shipping_address_1'];
    wayForPay = json['wayforpay'];
    active = json['active'];
    stripe = StripePay.fromJson(json['stripe']);
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }

    if (json['totals'] != null) {
      totals = <Totals>[];
      json['totals'].forEach((v) {
        totals!.add(Totals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['oid'] = oid;
    data['shipping_firstname'] = shippingFirstname;
    data['telz'] = telZ;
    data['date'] = date;
    data['vrem'] = time;
    data['mono_pay'] = monoPay;
    data['shipping_address_1'] = shippingAddress;
    data['wayforpay'] = wayForPay;
    data['active'] = active;
    data['stripe'] = stripe!.toJson();
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (totals != null) {
      data['totals'] = totals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  late int? cartId;
  late String? sessionId;
  late int? productId;
  late int? quantity;
  late dynamic index;
  late Product? product;

  Cart(
      {required this.cartId,
        required this.sessionId,
        required this.productId,
        required this.quantity,
        required this.index,
        required this.product});

  Cart.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    sessionId = json['session_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    index = json['index'];
    product = Product.fromJson(json['product']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['session_id'] = sessionId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['index'] = index;
    data['product'] = product!.toJson();
    return data;
  }
}

class Product {
  late int? productId;
  late String? name;
  late String? sku;
  late int? minimum;
  late int? quantity;
  late int? sezon;
  late int? razr;
  late String? description;
  late String? image;
  late String? video;
  late List<String>? images;
  late Map<String, dynamic>? variants;
  late int? popular;
  late String? vazaName;
  late int? vazaId;
  late int? vaza;
  late String? price;
  late String? total;
  late String? url;
  late List<Products>? products;
  late List<String>? payIcons;
  late List<Products>? viewed;
  late List<Qws>? qws;

  Product(
      {required this.productId,
        required this.name,
        required this.sku,
        required this.minimum,
        required this.quantity,
        required this.sezon,
        required this.razr,
        required this.description,
        required this.image,
        required this.video,
        required this.images,
        required this.variants,
        required this.popular,
        required this.vazaName,
        required this.vazaId,
        required this.vaza,
        required this.price,
        required this.total,
        required this.url,
        required this.products,
        required this.payIcons,
        required this.viewed,
        required this.qws});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'];
    sku = json['sku'];
    minimum = json['minimum'];
    quantity = json['quantity'];
    sezon = json['sezon'];
    razr = json['razr'];
    description = json['description'];
    image = json['image'];
    video = json['video'];
    url = json['url'];
    if (json['images'] != null) {
      images = <String>[];
      json['images'].forEach((v) {
        images!.add(v);
      });
    }
    if (json['pay_icons'] != null) {
      payIcons = <String>[];
      json['pay_icons'].forEach((v) {
        payIcons!.add(v);
      });
    }
    variants = json['variants'];
    popular = json['popular'];
    vazaName = json['vaza_name'];
    vazaId = json['vaza_id'];
    vaza = json['vaza'];
    price = json['price'];
    total = json['total'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    if (json['viewed'] != null) {
      viewed = <Products>[];
      json['viewed'].forEach((v) {
        viewed!.add(Products.fromJson(v));
      });
    }
    if (json['qws'] != null) {
      qws = <Qws>[];
      json['qws'].forEach((v) {
        qws!.add(Qws.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['name'] = name;
    data['sku'] = sku;
    data['minimum'] = minimum;
    data['quantity'] = quantity;
    data['sezon'] = sezon;
    data['razr'] = razr;
    data['description'] = description;
    data['image'] = image;
    data['video'] = video;
    data['url'] = url;
    if (images != null) {
      data['images'] = images;
    }
    if (payIcons != null) {
      data['pay_icons'] = payIcons;
    }
    data['variants'] = variants;
    data['popular'] = popular;
    data['vaza_name'] = vazaName;
    data['vaza_id'] = vazaId;
    data['vaza'] = vaza;
    data['price'] = price;
    data['total'] = total;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (viewed != null) {
      data['viewed'] = viewed!.map((v) => v.toJson()).toList();
    }
    if (qws != null) {
      data['qws'] = qws!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variant {
  late List<Sost>? sost;
  late String? sku;
  late String? image;
  late String? special;
  late String? price;
  late dynamic priceInt;

  Variant({required this.sost, required this.sku, required this.image, required this.special, required this.price, required this.priceInt});

  Variant.fromJson(Map<String, dynamic> json) {
    if (json['sost'] != null) {
      sost = <Sost>[];
      json['sost'].forEach((v) {
        sost!.add(Sost.fromJson(v));
      });
    }
    sku = json['sku'];
    image = json['image'];
    special = json['special'];
    price = json['price'];
    priceInt = json['price_int'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sost'] = sost!.map((v) => v.toJson()).toList();
    data['sku'] = sku;
    data['image'] = image;
    data['special'] = special;
    data['price'] = price;
    data['price_int'] = priceInt;
    return data;
  }
}

class Qws {
  late int? id;
  late String? product;
  late int? qw;
  late String? name;
  late int? use;
  late int? use2;
  late String? index;
  late String? price;
  late int? pids;
  late int? productId;

  Qws(
      {required this.id,
        required this.product,
        required this.qw,
        required this.name,
        required this.use,
        required this.use2,
        required this.index,
        required this.price,
        required this.pids,
        required this.productId});

  Qws.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product = json['product'];
    qw = json['qw'];
    name = json['name'];
    use = json['use'];
    use2 = json['use2'];
    index = json['index'];
    price = json['price'];
    pids = json['pids'];
    productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product'] = product;
    data['qw'] = qw;
    data['name'] = name;
    data['use'] = use;
    data['use2'] = use2;
    data['index'] = index;
    data['price'] = price;
    data['pids'] = pids;
    data['product_id'] = productId;
    return data;
  }
}

class Sost {
  late int? id;
  late String? name;
  late int? qw;
  late int? razr;

  Sost({required this.id, required this.name, required this.qw, required this.razr});

  Sost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    qw = json['qw'];
    razr = json['razr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['qw'] = qw;
    data['razr'] = razr;
    return data;
  }
}

class Totals {
  late String? code;
  late String? title;
  late String? string;
  late dynamic value;
  late String? text;
  late String? sortOrder;

  Totals(
      {required this.code,
        required this.title,
        required this.string,
        required this.value,
        required this.text,
        required this.sortOrder});

  Totals.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    title = json['title'];
    string = json['string'];
    value = json['value'];
    text = json['text'];
    sortOrder = json['sort_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['title'] = title;
    data['string'] = string;
    data['value'] = value;
    data['text'] = text;
    data['sort_order'] = sortOrder;
    return data;
  }
}

class Categories {
  late int? categoryId;
  late int? parentId;
  late String? name;
  late List<Products>? products;
  int? top;
  String? image;
  late int? pages;
  late List<Filters>? filters;
  late List<Categories>? children;

  Categories(
      {required this.categoryId, required this.parentId, required this.name, required this.products, this.top, this.image, required this.pages, required this.filters, required this.children});

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    parentId = json['parent_id'];
    name = json['name'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    top = json['top'];
    image = json['image'];
    pages = json['pages'];
    if (json['filters'] != null) {
      filters = <Filters>[];
      json['filters'].forEach((v) {
        filters!.add(Filters.fromJson(v));
      });
    }
    if (json['children'] != null) {
      children = <Categories>[];
      json['children'].forEach((v) {
        children!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['parent_id'] = parentId;
    data['name'] = name;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['top'] = top;
    data['image'] = image;
    data['pages'] = pages;
    if (filters != null) {
      data['filters'] = filters!.map((v) => v.toJson()).toList();
    }
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  late int? productId;
  late String? image;
  late String? name;
  late String? sku;
  late String? price;
  late String? special;
  late String? percent;
  late String? total;
  late int? cartId;
  late int? cartQuantity;

  Products(
      {required this.productId,
        required this.image,
        required this.name,
        required this.sku,
        required this.price,
        required this.special,
        required this.percent,
        required this.total,
        required this.cartId,
        required this.cartQuantity});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    image = json['image'];
    name = json['name'];
    sku = json['sku'];
    price = json['price'];
    special = json['special'];
    percent = json['percent'].toString().replaceFirst("-", "");
    total = json['total'];
    cartId = json['cart_id'];
    cartQuantity = json['cart_quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['image'] = image;
    data['name'] = name;
    data['sku'] = sku;
    data['price'] = price;
    data['special'] = special;
    data['percent'] = percent.toString().replaceFirst("-", "");
    data['total'] = total;
    data['cartId'] = cartId;
    data['cartQuantity'] = cartQuantity;
    return data;
  }
}

class Filters {
  late int? filterGroupId;
  late String? name;
  late List<Filter>? filter;
  late int? active;
  late bool? popup;

  Filters(
      {required this.filterGroupId, required this.name, required this.filter, required this.active, required this.popup});

  Filters.fromJson(Map<String, dynamic> json) {
    filterGroupId = json['filter_group_id'];
    name = json['name'];
    if (json['filter'] != null) {
      filter = <Filter>[];
      json['filter'].forEach((v) {
        filter!.add(Filter.fromJson(v));
      });
    }
    active = json['active'];
    popup = json['popup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter_group_id'] = filterGroupId;
    data['name'] = name;
    if (filter != null) {
      data['filter'] = filter!.map((v) => v.toJson()).toList();
    }
    data['active'] = active;
    data['popup'] = popup;
    return data;
  }
}

class Filter {
  late int? filterId;
  late String? name;
  late String? value;
  late String? val;
  late bool? active;

  Filter({required this.filterId, required this.name, required this.value, required this.active});

  Filter.fromJson(Map<String, dynamic> json) {
    filterId = json['filter_id'];
    name = json['name'];
    value = json['value'];
    val = json['val'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter_id'] = filterId;
    data['name'] = name;
    data['value'] = value;
    data['val'] = val;
    data['active'] = active;
    return data;
  }
}

class Languages {
  late String? name;
  late String? code;
  late int? languageId;
  late String? code2;

  Languages({required this.name, required this.code, required this.languageId, required this.code2});

  Languages.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    languageId = json['language_id'];
    code2 = json['code2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['language_id'] = languageId;
    data['code2'] = code2;
    return data;
  }
}

class Currencies {
  String? title;
  String? code;
  int? currencyId;
  String? symbolLeft;
  String? symbolRight;
  String? decimalPlace;
  num? value;

  Currencies(
      {this.title,
        this.code,
        this.currencyId,
        this.symbolLeft,
        this.symbolRight,
        this.decimalPlace,
        this.value});

  Currencies.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    code = json['code'];
    currencyId = json['currency_id'];
    symbolLeft = json['symbol_left'];
    symbolRight = json['symbol_right'];
    decimalPlace = json['decimal_place'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['code'] = code;
    data['currency_id'] = currencyId;
    data['symbol_left'] = symbolLeft;
    data['symbol_right'] = symbolRight;
    data['decimal_place'] = decimalPlace;
    data['value'] = value;
    return data;
  }
}

class Regions {
  late int? id;
  late String? name;
  String? flag = "assets/image/no_image.png";
  List<Cities>? cities;

  Regions({required this.id, required this.name, required this.flag, this.cities});

  Regions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    flag = json['flag'];
    if (json['cities'] != null) {
      cities = <Cities>[];
      json['cities'].forEach((v) {
        cities!.add(Cities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['flag'] = flag;
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cities {
  late int? id;
  String? image;
  late String? name;

  Cities({required this.id, this.image, required this.name});

  Cities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}

class Wishlist {
  int? productId;
  String? image;
  String? name;
  String? sku;
  String? price;
  String? special;

  Wishlist(
      {this.productId,
        this.image,
        this.name,
        this.sku,
        this.price,
        this.special});

  Wishlist.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    image = json['image'];
    name = json['name'];
    sku = json['sku'];
    price = json['price'];
    special = json['special'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['image'] = image;
    data['name'] = name;
    data['sku'] = sku;
    data['price'] = price;
    data['special'] = special;
    return data;
  }
}

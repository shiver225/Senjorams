import 'dart:convert';

class Place {
    String? formattedAddress;
    double? rating;
    RegularOpeningHours? regularOpeningHours;
    int? userRatingCount;
    String? iconMaskBaseUri;
    String? iconBackgroundColor;
    DisplayName? displayName;
    List<Review>? reviews;
    List<Photo>? photos;

    Place({
        this.formattedAddress,
        this.rating,
        this.regularOpeningHours,
        this.userRatingCount,
        this.iconMaskBaseUri,
        this.iconBackgroundColor,
        this.displayName,
        this.reviews,
        this.photos,
    });

    factory Place.fromRawJson(String str) => Place.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Place.fromJson(Map<String, dynamic> json) => Place(
        formattedAddress: json["formattedAddress"],
        rating: json["rating"]?.toDouble(),
        regularOpeningHours: json.containsKey("regularOpeningHours") ? RegularOpeningHours.fromJson(json["regularOpeningHours"]) : null,
        userRatingCount: json["userRatingCount"],
        iconMaskBaseUri: json["iconMaskBaseUri"],
        iconBackgroundColor: json["iconBackgroundColor"],
        displayName: json.containsKey("displayName") ? DisplayName.fromJson(json["displayName"]): null,
        reviews: json.containsKey("reviews") ? List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))): null,
        photos: json.containsKey("photos") ? List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))): null,
    );

    Map<String, dynamic> toJson() => {
        "formattedAddress": formattedAddress,
        "rating": rating,
        "regularOpeningHours": regularOpeningHours?.toJson(),
        "userRatingCount": userRatingCount,
        "iconMaskBaseUri": iconMaskBaseUri,
        "iconBackgroundColor": iconBackgroundColor,
        "displayName": displayName?.toJson(),
        "reviews": reviews!=null ? List<dynamic>.from(reviews!.map((x) => x.toJson())) : "",
        "photos": photos!=null ? List<dynamic>.from(photos!.map((x) => x.toJson())): "",
    };
}

class DisplayName {
    String text;
    String languageCode;

    DisplayName({
        required this.text,
        required this.languageCode,
    });

    factory DisplayName.fromRawJson(String str) => DisplayName.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DisplayName.fromJson(Map<String, dynamic> json) => DisplayName(
        text: json["text"],
        languageCode: json["languageCode"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "languageCode": languageCode,
    };
}

class Photo {
    String name;
    int widthPx;
    int heightPx;
    List<AuthorAttribution> authorAttributions;

    Photo({
        required this.name,
        required this.widthPx,
        required this.heightPx,
        required this.authorAttributions,
    });

    factory Photo.fromRawJson(String str) => Photo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        name: json["name"],
        widthPx: json["widthPx"],
        heightPx: json["heightPx"],
        authorAttributions: List<AuthorAttribution>.from(json["authorAttributions"].map((x) => AuthorAttribution.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "widthPx": widthPx,
        "heightPx": heightPx,
        "authorAttributions": List<dynamic>.from(authorAttributions.map((x) => x.toJson())),
    };
}

class AuthorAttribution {
    String displayName;
    String uri;
    String photoUri;

    AuthorAttribution({
        required this.displayName,
        required this.uri,
        required this.photoUri,
    });

    factory AuthorAttribution.fromRawJson(String str) => AuthorAttribution.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AuthorAttribution.fromJson(Map<String, dynamic> json) => AuthorAttribution(
        displayName: json["displayName"],
        uri: json["uri"],
        photoUri: json["photoUri"],
    );

    Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "uri": uri,
        "photoUri": photoUri,
    };
}

class RegularOpeningHours {
    bool openNow;
    List<Period> periods;
    List<String> weekdayDescriptions;

    RegularOpeningHours({
        required this.openNow,
        required this.periods,
        required this.weekdayDescriptions,
    });

    factory RegularOpeningHours.fromRawJson(String str) => RegularOpeningHours.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory RegularOpeningHours.fromJson(Map<String, dynamic> json) => RegularOpeningHours(
        openNow: json["openNow"],
        periods: List<Period>.from(json["periods"].map((x) => Period.fromJson(x))),
        weekdayDescriptions: List<String>.from(json["weekdayDescriptions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "openNow": openNow,
        "periods": List<dynamic>.from(periods.map((x) => x.toJson())),
        "weekdayDescriptions": List<dynamic>.from(weekdayDescriptions.map((x) => x)),
    };
}

class Period {
    Time? open;
    Time? close;

    Period({
        this.open,
        this.close,
    });

    factory Period.fromRawJson(String str) => Period.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Period.fromJson(Map<String, dynamic> json) => Period(
        open: json.containsKey("open") ? Time.fromJson(json["open"]) : null,
        close: json.containsKey("close") ? Time.fromJson(json["close"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "open": open?.toJson(),
        "close": close?.toJson(),
    };
}

class Time {
    int day;
    int hour;
    int minute;

    Time({
        required this.day,
        required this.hour,
        required this.minute,
    });

    factory Time.fromRawJson(String str) => Time.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Time.fromJson(Map<String, dynamic> json) => Time(
        day: json["day"],
        hour: json["hour"],
        minute: json["minute"],
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "hour": hour,
        "minute": minute,
    };
}

class Review {
    String name;
    String relativePublishTimeDescription;
    int rating;
    DisplayName? text;
    DisplayName? originalText;
    AuthorAttribution authorAttribution;
    DateTime publishTime;

    Review({
        required this.name,
        required this.relativePublishTimeDescription,
        required this.rating,
        this.text,
        this.originalText,
        required this.authorAttribution,
        required this.publishTime,
    });

    factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        name: json["name"],
        relativePublishTimeDescription: json["relativePublishTimeDescription"],
        rating: json["rating"],
        text: json["text"] == null ? null : DisplayName.fromJson(json["text"]),
        originalText: json["originalText"] == null ? null : DisplayName.fromJson(json["originalText"]),
        authorAttribution: AuthorAttribution.fromJson(json["authorAttribution"]),
        publishTime: DateTime.parse(json["publishTime"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "relativePublishTimeDescription": relativePublishTimeDescription,
        "rating": rating,
        "text": text?.toJson(),
        "originalText": originalText?.toJson(),
        "authorAttribution": authorAttribution.toJson(),
        "publishTime": publishTime.toIso8601String(),
    };
}

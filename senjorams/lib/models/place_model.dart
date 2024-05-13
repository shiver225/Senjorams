import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
    String? formattedAddress;
    double? rating;
    _RegularOpeningHours? regularOpeningHours;
    int? userRatingCount;
    String? id;
    String? iconMaskBaseUri;
    String? iconBackgroundColor;
    _DisplayName? displayName;
    List<_Review>? reviews;
    List<_Photo>? photos;
    Color cardColor = Colors.white;
    bool isSelected = false;
    LatLng? location;
    Place({
        this.location,
        this.id,
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
        location: LatLng(json["location"]["latitude"],json["location"]["longitude"]),
        id: json["id"],
        formattedAddress: json["formattedAddress"],
        rating: json["rating"]?.toDouble(),
        regularOpeningHours: json.containsKey("regularOpeningHours") ? _RegularOpeningHours.fromJson(json["regularOpeningHours"]) : null,
        userRatingCount: json["userRatingCount"],
        iconMaskBaseUri: json["iconMaskBaseUri"],
        iconBackgroundColor: json["iconBackgroundColor"],
        displayName: json.containsKey("displayName") ? _DisplayName.fromJson(json["displayName"]): null,
        reviews: json.containsKey("reviews") ? List<_Review>.from(json["reviews"].map((x) => _Review.fromJson(x))): null,
        photos: json.containsKey("photos") ? List<_Photo>.from(json["photos"].map((x) => _Photo.fromJson(x))): null,
    );

    Map<String, dynamic> toJson() => {
        "location": {"latitude":location!.latitude, "longitude":location!.longitude},
        "id": id,
        "formattedAddress": formattedAddress,
        "rating": rating,
        if (regularOpeningHours != null) "regularOpeningHours": regularOpeningHours!.toJson(),
        "userRatingCount": userRatingCount,
        "iconMaskBaseUri": iconMaskBaseUri,
        "iconBackgroundColor": iconBackgroundColor,
        if (displayName != null) "displayName": displayName!.toJson(),
        if (reviews != null) "reviews": List<dynamic>.from(reviews!.map((x) => x.toJson())),
        if (photos != null) "photos": List<dynamic>.from(photos!.map((x) => x.toJson())),
    };
}

class _DisplayName {
    String text;
    String languageCode;

    _DisplayName({
        required this.text,
        required this.languageCode,
    });

    factory _DisplayName.fromRawJson(String str) => _DisplayName.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _DisplayName.fromJson(Map<String, dynamic> json) => _DisplayName(
        text: json["text"],
        languageCode: json["languageCode"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "languageCode": languageCode,
    };
}

class _Photo {
    String name;
    int widthPx;
    int heightPx;
    List<_AuthorAttribution> authorAttributions;

    _Photo({
        required this.name,
        required this.widthPx,
        required this.heightPx,
        required this.authorAttributions,
    });

    factory _Photo.fromRawJson(String str) => _Photo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _Photo.fromJson(Map<String, dynamic> json) => _Photo(
        name: json["name"],
        widthPx: json["widthPx"],
        heightPx: json["heightPx"],
        authorAttributions: List<_AuthorAttribution>.from(json["authorAttributions"].map((x) => _AuthorAttribution.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "widthPx": widthPx,
        "heightPx": heightPx,
        "authorAttributions": List<dynamic>.from(authorAttributions.map((x) => x.toJson())),
    };
}

class _AuthorAttribution {
    String displayName;
    String uri;
    String photoUri;

    _AuthorAttribution({
        required this.displayName,
        required this.uri,
        required this.photoUri,
    });

    factory _AuthorAttribution.fromRawJson(String str) => _AuthorAttribution.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _AuthorAttribution.fromJson(Map<String, dynamic> json) => _AuthorAttribution(
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

class _RegularOpeningHours {
    bool openNow;
    List<_Period> periods;
    List<String> weekdayDescriptions;

    _RegularOpeningHours({
        required this.openNow,
        required this.periods,
        required this.weekdayDescriptions,
    });

    factory _RegularOpeningHours.fromRawJson(String str) => _RegularOpeningHours.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _RegularOpeningHours.fromJson(Map<String, dynamic> json) => _RegularOpeningHours(
        openNow: json["openNow"],
        periods: List<_Period>.from(json["periods"].map((x) => _Period.fromJson(x))),
        weekdayDescriptions: List<String>.from(json["weekdayDescriptions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "openNow": openNow,
        "periods": List<dynamic>.from(periods.map((x) => x.toJson())),
        "weekdayDescriptions": List<dynamic>.from(weekdayDescriptions.map((x) => x)),
    };
}

class _Period {
    _Time? open;
    _Time? close;

    _Period({
        this.open,
        this.close,
    });

    factory _Period.fromRawJson(String str) => _Period.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _Period.fromJson(Map<String, dynamic> json) => _Period(
        open: json.containsKey("open") ? _Time.fromJson(json["open"]) : null,
        close: json.containsKey("close") ? _Time.fromJson(json["close"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "open": open?.toJson(),
        "close": close?.toJson(),
    };
}

class _Time {
    int day;
    int hour;
    int minute;

    _Time({
        required this.day,
        required this.hour,
        required this.minute,
    });

    factory _Time.fromRawJson(String str) => _Time.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _Time.fromJson(Map<String, dynamic> json) => _Time(
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

class _Review {
    String name;
    String relativePublishTimeDescription;
    int rating;
    _DisplayName? text;
    _DisplayName? originalText;
    _AuthorAttribution authorAttribution;
    DateTime publishTime;

    _Review({
        required this.name,
        required this.relativePublishTimeDescription,
        required this.rating,
        this.text,
        this.originalText,
        required this.authorAttribution,
        required this.publishTime,
    });

    factory _Review.fromRawJson(String str) => _Review.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory _Review.fromJson(Map<String, dynamic> json) => _Review(
        name: json["name"],
        relativePublishTimeDescription: json["relativePublishTimeDescription"],
        rating: json["rating"],
        text: json["text"] == null ? null : _DisplayName.fromJson(json["text"]),
        originalText: json["originalText"] == null ? null : _DisplayName.fromJson(json["originalText"]),
        authorAttribution: _AuthorAttribution.fromJson(json["authorAttribution"]),
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

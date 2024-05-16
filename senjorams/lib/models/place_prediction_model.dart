class PlacePrediction {
    String place;
    String placeId;
    _Text text;
    _StructuredFormat structuredFormat;
    List<String> types;

    PlacePrediction({
        required this.place,
        required this.placeId,
        required this.text,
        required this.structuredFormat,
        required this.types,
    });

    factory PlacePrediction.fromJson(Map<String, dynamic> json) => PlacePrediction(
        place: json["place"],
        placeId: json["placeId"],
        text: _Text.fromJson(json["text"]),
        structuredFormat: _StructuredFormat.fromJson(json["structuredFormat"]),
        types: List<String>.from(json["types"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "place": place,
        "placeId": placeId,
        "text": text.toJson(),
        "structuredFormat": structuredFormat.toJson(),
        "types": List<dynamic>.from(types.map((x) => x)),
    };
}

class _StructuredFormat {
    _Text mainText;
    _SecondaryText secondaryText;

    _StructuredFormat({
        required this.mainText,
        required this.secondaryText,
    });

    factory _StructuredFormat.fromJson(Map<String, dynamic> json) => _StructuredFormat(
        mainText: _Text.fromJson(json["mainText"]),
        secondaryText: _SecondaryText.fromJson(json["secondaryText"]),
    );

    Map<String, dynamic> toJson() => {
        "mainText": mainText.toJson(),
        "secondaryText": secondaryText.toJson(),
    };
}

class _Text {
    String text;
    List<_Match> matches;

    _Text({
        required this.text,
        required this.matches,
    });

    factory _Text.fromJson(Map<String, dynamic> json) => _Text(
        text: json["text"],
        matches: List<_Match>.from(json["matches"].map((x) => _Match.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "matches": List<dynamic>.from(matches.map((x) => x.toJson())),
    };
}

class _Match {
    int endOffset;

    _Match({
        required this.endOffset,
    });

    factory _Match.fromJson(Map<String, dynamic> json) => _Match(
        endOffset: json["endOffset"],
    );

    Map<String, dynamic> toJson() => {
        "endOffset": endOffset,
    };
}

class _SecondaryText {
    String text;

    _SecondaryText({
        required this.text,
    });

    factory _SecondaryText.fromJson(Map<String, dynamic> json) => _SecondaryText(
        text: json["text"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
    };
}
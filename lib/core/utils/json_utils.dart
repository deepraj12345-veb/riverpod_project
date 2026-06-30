Object? readId(Map json, String key) {
  return json['_id'] ??
      json['id'] ??
      json['product_id'] ??
      json['category_id'] ??
      json['category_type_id'] ??
      json['banner_id'] ??
      '';
}

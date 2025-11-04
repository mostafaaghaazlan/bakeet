class GetListRequest {
  int? skip;
  int? take;

  GetListRequest({this.skip, this.take});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (skip != null) data['SkipCount'] = skip;
    if (take != null) data['MaxResultCount'] = take;
    return data;
  }
}

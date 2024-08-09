

import 'package:http/http.dart' as http;
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/core/utilities/enum.dart';


///
/// swapper importable api url
/// https://polls-beta.hivehub.dev/
///
/// hive polls docs reference:
/// https://gitlab.com/peakd/hive-open-polls
///

Future<ActionSingleDataResponse<PollModel>> fetchPoll(
    String author,
    String permlink
  ) async {
    try {
      var url = Uri.parse(
          "https://polls.hivehub.dev/rpc/poll?author=eq.$author&permlink=eq.$permlink");

 

      http.Response response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        return ActionSingleDataResponse<PollModel>(
            data: PollModel.fromJsonString(response.body).first,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionSingleDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('google')
external _Google get _gsi;

extension type _Google._(JSObject _) implements JSObject {
  external _Accounts get accounts;
}

extension type _Accounts._(JSObject _) implements JSObject {
  external _Id get id;
}

extension type _Id._(JSObject _) implements JSObject {
  external void initialize(JSObject config);
  external void prompt(JSFunction momentListener);
  external void cancel();
}

extension type _CredentialResponse._(JSObject _) implements JSObject {
  external String? get credential;
}

extension type _PromptMoment._(JSObject _) implements JSObject {
  external bool isNotDisplayed();
  external bool isSkippedMoment();
  external bool isDismissedMoment();
  external String getNotDisplayedReason();
  external String getDismissedReason();
}

Completer<String>? _pending;

Future<String> getGoogleIdTokenWeb(String clientId) {
  _pending?.completeError(Exception('Superseded'));
  final completer = Completer<String>();
  _pending = completer;

  final callback = ((JSObject raw) {
    final idToken = _CredentialResponse._(raw).credential;
    if (idToken != null && idToken.isNotEmpty) {
      _pending?.complete(idToken);
    } else {
      _pending?.completeError(Exception('No credential in Google response'));
    }
    _pending = null;
  }).toJS;

  final config = {
    'client_id': clientId,
    'auto_select': false,
    'cancel_on_tap_outside': false,
    'context': 'signin',
  }.jsify()! as JSObject;
  config['callback'] = callback;

  _gsi.accounts.id.initialize(config);

  _gsi.accounts.id.prompt(((JSObject raw) {
    final moment = _PromptMoment._(raw);
    if (moment.isNotDisplayed()) {
      _pending?.completeError(
        Exception('Sign-in not displayed: ${moment.getNotDisplayedReason()}'),
      );
      _pending = null;
    } else if (moment.isDismissedMoment()) {
      _pending?.completeError(Exception('Sign-in dismissed by user'));
      _pending = null;
    }
  }).toJS);

  return completer.future;
}

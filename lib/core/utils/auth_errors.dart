const authErrAccountNotFound = 'ACCOUNT_NOT_FOUND';

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

bool isAccountNotFoundError(String? error) =>
    error == authErrAccountNotFound ||
    (error ?? '').toLowerCase().contains('account not registered');

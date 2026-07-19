const authErrAccountNotFound = 'ACCOUNT_NOT_FOUND';

bool isAccountNotFoundError(String? error) =>
    error == authErrAccountNotFound ||
    (error ?? '').toLowerCase().contains('account not registered');

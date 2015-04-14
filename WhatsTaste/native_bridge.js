function call_native(method, arguments, callback)
{
    native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback);
}

function callback_to_native(callback, arguments, callbackPlus)
{
    alert(callback)
    callback(arguments);
}
function call_native(method, arguments)
{
    var callback = arguments['callback'];
    if (callback == 'undefined') {
        native.callNativeMethodArguments(method, arguments);
    } else {
        native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback);
    }
}

function callback_to_native(callback, arguments)
{
    callback(arguments);
}
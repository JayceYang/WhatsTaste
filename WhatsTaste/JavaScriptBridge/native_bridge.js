function call_native(arguments)
{
    var callback = arguments['callback'];
    if (callback == 'undefined') {
        native.callNativeMethodWithArguments(arguments);
    } else {
        native.callNativeMethodWithArgumentsCompletionHandler(arguments, callback);
    }
}

function callback_to_native(callback, arguments)
{
    callback(arguments);
}
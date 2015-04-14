function call_native(method, arguments, callback)
{
    alert(callback)
    if (callback == 'undefined') {
        native.callNativeMethodArguments(method, arguments);
    } else {
        native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback);
    }
}

//function call_native(method, arguments)
//{
//    native.callNativeMethodArguments(method, arguments);
//}

function callback_to_native(callback, arguments, callbackPlus)
{
    alert(callback)
    callback(arguments, callbackPlus);
}
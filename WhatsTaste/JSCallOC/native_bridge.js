function call_native(method, arguments, callback)
{
    native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback);
}

function callback_to_native(callback, arguments, callbackPlus)
{
    callback(arguments, callbackPlus);
}

//function updateResult(resultNumber)
//{
//    document.getElementById("result").innerText = resultNumber;
//}
//
//function jsSquare(number)
//{
//    resultNumber = number * number;
//    document.getElementById("result").innerText = resultNumber
//}
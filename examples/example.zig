const std = @import("std");

const c = @cImport({
    @cInclude("boxer/boxer.h");
});

fn checkError(response: c.BoxerSelection) !void {
    if (response == c.BoxerSelectionError) return error.BoxerError;
}

pub fn main() !void {
    try checkError(c.boxerShow(
        "Simple message boxes are very easy to create.",
        "Simple Example",
        c.kBoxerDefaultStyle,
        c.kBoxerDefaultButtons,
    ));

    try checkError(c.boxerShow(
        "Boxer accepts UTF-8 strings. 💯",
        "Unicode 👍",
        c.kBoxerDefaultStyle,
        c.kBoxerDefaultButtons,
    ));

    try checkError(c.boxerShow(
        "There are a few different message box styles to choose from.",
        "Style Example",
        c.BoxerStyleError,
        c.kBoxerDefaultButtons,
    ));

    while (c.boxerShow(
        "Different buttons may be used, and the user's selection can be checked. Would you like to see this message again?",
        "Selection Example",
        c.BoxerStyleQuestion,
        c.BoxerButtonsYesNo,
    ) == c.BoxerSelectionYes) {}
}

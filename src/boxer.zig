const builtin = @import("builtin");
const std = @import("std");

usingnamespace switch (builtin.os.tag) {
    .linux => struct {
        pub var instance: ?std.DynLib = null;

        const c = @cImport({
            @cInclude("boxer/boxer.h");
        });

        const gboolean = c_int;
        const GtkWidget = opaque {};
        const GtkWindow = opaque {};
        const GtkDialog = opaque {};
        const GMainContext = opaque {};

        const GTK_DIALOG_MODAL: c_int = 1;
        const GTK_DIALOG_DESTROY_WITH_PARENT: c_int = 2;
        const GTK_DIALOG_USE_HEADER_BAR: c_int = 4;
        const GtkDialogFlags = c_uint;

        const GTK_MESSAGE_INFO: c_int = 0;
        const GTK_MESSAGE_WARNING: c_int = 1;
        const GTK_MESSAGE_QUESTION: c_int = 2;
        const GTK_MESSAGE_ERROR: c_int = 3;
        const GTK_MESSAGE_OTHER: c_int = 4;
        const GtkMessageType = c_uint;

        const GTK_WINDOW_TOPLEVEL: c_int = 0;
        const GTK_WINDOW_POPUP: c_int = 1;
        const GtkWindowType = c_uint;

        const GTK_BUTTONS_NONE: c_int = 0;
        const GTK_BUTTONS_OK: c_int = 1;
        const GTK_BUTTONS_CLOSE: c_int = 2;
        const GTK_BUTTONS_CANCEL: c_int = 3;
        const GTK_BUTTONS_YES_NO: c_int = 4;
        const GTK_BUTTONS_OK_CANCEL: c_int = 5;
        const GtkButtonsType = c_uint;

        const GTK_RESPONSE_NONE: c_int = -1;
        const GTK_RESPONSE_REJECT: c_int = -2;
        const GTK_RESPONSE_ACCEPT: c_int = -3;
        const GTK_RESPONSE_DELETE_EVENT: c_int = -4;
        const GTK_RESPONSE_OK: c_int = -5;
        const GTK_RESPONSE_CANCEL: c_int = -6;
        const GTK_RESPONSE_CLOSE: c_int = -7;
        const GTK_RESPONSE_YES: c_int = -8;
        const GTK_RESPONSE_NO: c_int = -9;
        const GTK_RESPONSE_APPLY: c_int = -10;
        const GTK_RESPONSE_HELP: c_int = -11;
        const GtkResponseType = c_int;

        const GtkInitCheck = *const fn (argc: c_int, argv: ?[*]?[*]?[*]u8) callconv(.C) gboolean;
        const GtkWindowNew = *const fn (@"type": GtkWindowType) callconv(.C) *GtkWidget;
        const GtkMessageDialogNew = *const fn (
            parent: *GtkWindow,
            flags: GtkDialogFlags,
            @"type": GtkMessageType,
            buttons: GtkButtonsType,
            message_format: [*]const u8,
            ...,
        ) callconv(.C) *GtkWidget;
        const GtkWindowSetTitle = *const fn (window: *GtkWindow, title: ?[*]const u8) callconv(.C) void;
        const GtkDialogRun = *const fn (dialog: *GtkDialog) callconv(.C) c_int;
        const GtkWidgetDestroy = *const fn (widget: *GtkWidget) void;
        const GMainContextIteration = *const fn (context: ?*GMainContext, may_block: gboolean) gboolean;

        pub var gtk_init_check: GtkInitCheck = undefined;
        pub var gtk_window_new: GtkWindowNew = undefined;
        pub var gtk_message_dialog_new: GtkMessageDialogNew = undefined;
        pub var gtk_window_set_title: GtkWindowSetTitle = undefined;
        pub var gtk_dialog_run: GtkDialogRun = undefined;
        pub var gtk_widget_destroy: GtkWidgetDestroy = undefined;
        pub var g_main_context_iteration: GMainContextIteration = undefined;

        fn getMessageType(style: c.BoxerStyle) GtkMessageType {
            return switch (style) {
                c.BoxerStyleInfo => GTK_MESSAGE_INFO,
                c.BoxerStyleWarning => GTK_MESSAGE_WARNING,
                c.BoxerStyleError => GTK_MESSAGE_ERROR,
                c.BoxerStyleQuestion => GTK_MESSAGE_QUESTION,
                else => GTK_MESSAGE_INFO,
            };
        }

        fn getButtonsType(buttons: c.BoxerButtons) GtkButtonsType {
            return switch (buttons) {
                c.BoxerButtonsOK => GTK_BUTTONS_OK,
                c.BoxerButtonsOKCancel => GTK_BUTTONS_OK_CANCEL,
                c.BoxerButtonsYesNo => GTK_BUTTONS_YES_NO,
                c.BoxerButtonsQuit => GTK_BUTTONS_CLOSE,
                else => GTK_BUTTONS_OK,
            };
        }

        fn getSelection(response: GtkResponseType) c.BoxerSelection {
            return switch (response) {
                GTK_RESPONSE_OK => c.BoxerSelectionOK,
                GTK_RESPONSE_CANCEL => c.BoxerSelectionCancel,
                GTK_RESPONSE_YES => c.BoxerSelectionYes,
                GTK_RESPONSE_NO => c.BoxerSelectionNo,
                GTK_RESPONSE_CLOSE => c.BoxerSelectionQuit,
                else => c.BoxerSelectionNone,
            };
        }

        pub export fn boxerShow(message: [*]u8, title: [*]u8, style: c.BoxerStyle, buttons: c.BoxerButtons) callconv(.C) c.BoxerSelection {
            if (instance == null) {
                instance = std.DynLib.open("libgtk-3.so") catch {
                    std.debug.print("cant find gtk wat\n", .{});

                    return c.BoxerSelectionError;
                };
                gtk_init_check = instance.?.lookup(GtkInitCheck, "gtk_init_check") orelse return c.BoxerSelectionError;
                gtk_window_new = instance.?.lookup(GtkWindowNew, "gtk_window_new") orelse return c.BoxerSelectionError;
                gtk_message_dialog_new = instance.?.lookup(GtkMessageDialogNew, "gtk_message_dialog_new") orelse return c.BoxerSelectionError;
                gtk_window_set_title = instance.?.lookup(GtkWindowSetTitle, "gtk_window_set_title") orelse return c.BoxerSelectionError;
                gtk_dialog_run = instance.?.lookup(GtkDialogRun, "gtk_dialog_run") orelse return c.BoxerSelectionError;
                gtk_widget_destroy = instance.?.lookup(GtkWidgetDestroy, "gtk_widget_destroy") orelse return c.BoxerSelectionError;
                g_main_context_iteration = instance.?.lookup(GMainContextIteration, "g_main_context_iteration") orelse return c.BoxerSelectionError;
            }

            if (gtk_init_check(0, null) == 0) {
                return c.BoxerSelectionError;
            }

            const parent = gtk_window_new(GTK_WINDOW_TOPLEVEL);

            const dialog = gtk_message_dialog_new(
                @ptrCast(parent),
                GTK_DIALOG_MODAL,
                getMessageType(style),
                getButtonsType(buttons),
                "%s",
                message,
            );
            gtk_window_set_title(@ptrCast(dialog), title);

            const selection = getSelection(gtk_dialog_run(@ptrCast(dialog)));

            gtk_widget_destroy(@ptrCast(dialog));
            gtk_widget_destroy(@ptrCast(parent));

            while (g_main_context_iteration(null, 0) != 0) continue;

            return selection;
        }
    },
    else => struct {},
};

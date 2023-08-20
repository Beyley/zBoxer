const builtin = @import("builtin");
const std = @import("std");

usingnamespace switch (builtin.os.tag) {
    .linux => struct {
        pub var instance: ?std.DynLib = null;

        const c = @cImport({
            @cInclude("boxer/boxer.h");
            @cInclude("boxer_linux.c");
        });

        const GtkInitCheck = *const @TypeOf(c.gtk_init_check);
        const GtkWindowNew = *const @TypeOf(c.gtk_window_new);
        const GtkMessageDialogNew = *const @TypeOf(c.gtk_message_dialog_new);
        const GtkWindowSetTitle = *const @TypeOf(c.gtk_window_set_title);
        const GtkDialogRun = *const @TypeOf(c.gtk_dialog_run);
        const GtkWidgetDestroy = *const @TypeOf(c.gtk_widget_destroy);
        const GMainContextIteration = *const @TypeOf(c.g_main_context_iteration);

        pub var gtk_init_check: GtkInitCheck = undefined;
        pub var gtk_window_new: GtkWindowNew = undefined;
        pub var gtk_message_dialog_new: GtkMessageDialogNew = undefined;
        pub var gtk_window_set_title: GtkWindowSetTitle = undefined;
        pub var gtk_dialog_run: GtkDialogRun = undefined;
        pub var gtk_widget_destroy: GtkWidgetDestroy = undefined;
        pub var g_main_context_iteration: GMainContextIteration = undefined;

        pub export fn boxerShow(message: [*]u8, title: [*]u8, style: c.BoxerStyle, buttons: c.BoxerButtons) callconv(.C) c.BoxerSelection {
            if (instance == null) {
                instance = std.DynLib.open("libgtk-3.so") catch return c.BoxerSelectionError;
                gtk_init_check = instance.?.lookup(GtkInitCheck, "gtk_init_check") orelse return c.BoxerSelectionError;
                gtk_window_new = instance.?.lookup(GtkWindowNew, "gtk_window_new") orelse return c.BoxerSelectionError;
                gtk_message_dialog_new = instance.?.lookup(GtkMessageDialogNew, "gtk_message_dialog_new") orelse return c.BoxerSelectionError;
                gtk_window_set_title = instance.?.lookup(GtkWindowSetTitle, "gtk_window_set_title") orelse return c.BoxerSelectionError;
                gtk_dialog_run = instance.?.lookup(GtkDialogRun, "gtk_dialog_run") orelse return c.BoxerSelectionError;
                gtk_widget_destroy = instance.?.lookup(GtkWidgetDestroy, "gtk_widget_destroy") orelse return c.BoxerSelectionError;
                g_main_context_iteration = instance.?.lookup(GMainContextIteration, "g_main_context_iteration") orelse return c.BoxerSelectionError;
            }

            if (gtk_init_check(0, null) == c.FALSE) {
                return c.BoxerSelectionError;
            }

            const parent = gtk_window_new(c.GTK_WINDOW_TOPLEVEL);

            const dialog = gtk_message_dialog_new(
                @ptrCast(parent),
                c.GTK_DIALOG_MODAL,
                c.getMessageType(style),
                c.getButtonsType(buttons),
                "%s",
                message,
            );
            gtk_window_set_title(@ptrCast(dialog), title);

            const selection = c.getSelection(gtk_dialog_run(@ptrCast(dialog)));

            gtk_widget_destroy(@ptrCast(dialog));
            gtk_widget_destroy(@ptrCast(parent));

            while (g_main_context_iteration(null, c.FALSE) != 0) continue;

            return selection;
        }
    },
    else => struct {},
};

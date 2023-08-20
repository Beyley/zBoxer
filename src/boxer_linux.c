#include <boxer/boxer.h>
#include <gtk/gtk.h>

static GtkMessageType getMessageType(BoxerStyle style)
{
   switch (style)
   {
   case BoxerStyleInfo:
      return GTK_MESSAGE_INFO;
   case BoxerStyleWarning:
      return GTK_MESSAGE_WARNING;
   case BoxerStyleError:
      return GTK_MESSAGE_ERROR;
   case BoxerStyleQuestion:
      return GTK_MESSAGE_QUESTION;
   default:
      return GTK_MESSAGE_INFO;
   }
}

static GtkButtonsType getButtonsType(BoxerButtons buttons)
{
   switch (buttons)
   {
   case BoxerButtonsOK:
      return GTK_BUTTONS_OK;
   case BoxerButtonsOKCancel:
      return GTK_BUTTONS_OK_CANCEL;
   case BoxerButtonsYesNo:
      return GTK_BUTTONS_YES_NO;
   case BoxerButtonsQuit:
      return GTK_BUTTONS_CLOSE;
   default:
      return GTK_BUTTONS_OK;
   }
}

static BoxerSelection getSelection(gint response)
{
   switch (response)
   {
   case GTK_RESPONSE_OK:
      return BoxerSelectionOK;
   case GTK_RESPONSE_CANCEL:
      return BoxerSelectionCancel;
   case GTK_RESPONSE_YES:
      return BoxerSelectionYes;
   case GTK_RESPONSE_NO:
      return BoxerSelectionNo;
   case GTK_RESPONSE_CLOSE:
      return BoxerSelectionQuit;
   default:
      return BoxerSelectionNone;
   }
}

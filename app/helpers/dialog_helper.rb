module DialogHelper
  # Renders a complete dialog component including a trigger and modal.
  #
  # - trigger: The HTML for the button or link that opens the dialog.
  # - title:   The text to display in the dialog's h2 tag.
  # - label:   The accessible name for the dialog (defaults to title).
  # - size:    The max-width of the dialog (e.g., '500px').
  # - &block:  The content to be rendered inside the dialog body.
  #
  def modal_dialog(trigger, title: nil, label: nil, size: "430px", &block)
    content = capture(&block) if block

    render "layouts/shared/dialog",
      trigger: trigger,
      title:   title,
      label:   label || title,
      size:    size,
      content: content
  end
end

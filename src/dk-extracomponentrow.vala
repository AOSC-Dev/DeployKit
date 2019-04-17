namespace Dk {
  [GtkTemplate (ui = "/io/aosc/DeployKit/ui/dk-extracomponentrow.ui")]
  public class ExtraComponentRow : Gtk.Box {
    [GtkChild]
    private Gtk.Image icon;
    [GtkChild (name = "name")]
    private Gtk.Label component_name;
    [GtkChild]
    private Gtk.Label description;
    [GtkChild]
    private Gtk.Label download_size;
    [GtkChild]
    private Gtk.Label installation_size;

    public ExtraComponentRow(string icon_name, string component_name, string description, uint64 download_size, uint64 installation_size) {
      this.icon.set_from_icon_name(icon_name, Gtk.IconSize.DIALOG); // 48px
      this.component_name.set_text(component_name);
      this.description.set_text(description);
      this.download_size.set_text(GLib.format_size(download_size, GLib.FormatSizeFlags.IEC_UNITS));
      this.installation_size.set_text(GLib.format_size(installation_size, GLib.FormatSizeFlags.IEC_UNITS));
    }
  }
}
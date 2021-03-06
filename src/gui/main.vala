namespace Dk {
namespace Gui {

/**
 * Errors that may be thrown by ``load_recipe``.
 */
private errordomain LoadRecipeError {
  /** Parse error. */
  PARSE_ERROR,

  /** Unknown recipe version. */
  UNKNOWN_VERSION,
}

/**
 * Errors that may be thrown by ``load_disks``.
 */
private errordomain LoadDisksError {
  /** Connection error (cannot connect to UDisks DBus). */
  CONNECTION_ERROR,
}

/**
 * The main application window of DeployKit.
 */
[GtkTemplate (ui = "/io/aosc/DeployKit/ui/main.ui")]
public class Main : Gtk.ApplicationWindow {
  /* Widgets in Header Bar */
  [GtkChild]
  private Gtk.HeaderBar headerbar_main;
  [GtkChild]
  private Gtk.ToggleButton togglebtn_expert;
  [GtkChild]
  private Gtk.Button btn_back;
  [GtkChild]
  private Gtk.Button btn_ok;
  [GtkChild]
  private Gtk.Button btn_network;

  /* Bulletin */
  [GtkChild]
  private Gtk.Revealer revealer_bulletin;
  [GtkChild]
  private Gtk.Label label_bulletin_title;
  [GtkChild]
  private Gtk.Label label_bulletin_body;

  /* Main Switching Stack */
  [GtkChild]
  private Gtk.Stack stack_main;

  /* ========== Widgets in Page 1 (Prepare) ========== */
  [GtkChild]
  private Gtk.Box box_prepare;

  /* ========== Widgets in Page 2 (Recipe (General)) ========== */
  [GtkChild]
  private Gtk.Box box_recipe_general;

  /* Variant */
  [GtkChild]
  private Gtk.Button  btn_recipe_general_variant_clear;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_general_variant;

  /* Destination */
  [GtkChild]
  private Gtk.Button  btn_recipe_general_dest_refresh;
  [GtkChild]
  private Gtk.Button  btn_recipe_general_dest_clear;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_general_dest;
  [GtkChild]
  private Gtk.Button  btn_recipe_general_dest_partition;

  /* Mirror */
  [GtkChild]
  private Gtk.Button  btn_recipe_general_mirror_clear;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_general_mirror;

  /* Extra Components */
  [GtkChild]
  private Gtk.Button  btn_recipe_general_xcomps_clear;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_general_xcomps;

  /* System Configuration (See Shared Widgets) */
  [GtkChild]
  private Gtk.Entry entry_recipe_general_locale;
  [GtkChild]
  private Gtk.Entry entry_recipe_general_root_password_retype;
  [GtkChild]
  private Gtk.Entry entry_recipe_general_admin_password_retype;

  /* ========== Widgets in Page 3 (Recipe (Expert)) ========== */
  [GtkChild]
  private Gtk.Box     box_recipe_expert;

  /* Build-It-Yourself */
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_biy_clear;
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_biy_add;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_expert_biy;

  /* Extra Components */
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_xcomps_clear;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_expert_xcomps;

  /* Destination */
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_dest_clear;
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_dest_refresh;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_expert_dest;
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_dest_partition;

  /* Mirror */
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_mirror_clear;
  [GtkChild]
  private Gtk.Button  btn_recipe_expert_mirror_add;
  [GtkChild]
  private Gtk.ListBox listbox_recipe_expert_mirror;

  /* System Configuration (See Shared Widgets) */
  [GtkChild]
  private Gtk.Entry entry_recipe_expert_locale;
  [GtkChild]
  private Gtk.Entry entry_recipe_expert_root_password_retype;
  [GtkChild]
  private Gtk.Entry entry_recipe_expert_admin_password_retype;

  /* ========== Widgets in Page 4 (Confirm) ========== */
  [GtkChild]
  private Gtk.Box box_confirm;
  [GtkChild]
  private Gtk.Label label_confirm_variant;
  [GtkChild]
  private Gtk.Label label_confirm_dest;
  [GtkChild]
  private Gtk.Label label_confirm_mirror;
  [GtkChild]
  private Gtk.Label label_confirm_xcomps;
  [GtkChild]
  private Gtk.Label label_confirm_hostname;
  [GtkChild]
  private Gtk.Label label_confirm_locale;
  [GtkChild]
  private Gtk.Label label_confirm_admin_username;
  [GtkChild]
  private Gtk.Label label_confirm_info_missing_prompt;

  /* ========== Widgets in Page 5 (Installation) ========== */
  [GtkChild]
  private Gtk.Box   box_install;
  [GtkChild]
  private Gtk.Stack stack_installation_ad;
  [GtkChild]
  private Gtk.Label label_installation_step_curr;
  [GtkChild]
  private Gtk.Label label_installation_step_of;
  [GtkChild]
  private Gtk.Label label_installation_step_max;
  [GtkChild]
  private Gtk.Label label_installation_step_desc;
  [GtkChild]
  private Gtk.ProgressBar progressbar_installation;

  /* ========== Widgets in Page 6 (Done) ========== */
  [GtkChild]
  private Gtk.Box box_done;

  /* ========== Shared Widgets ========== */
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_hostname;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_locale;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_root_password;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_root_password_retype;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_admin_username;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_admin_password;
  [GtkChild]
  private Gtk.EntryBuffer entrybuffer_admin_password_retype;

  /* ========== Variables to Use ========== */
  private Gtk.Widget? last_page;

  private ProxyType? proxy_type;
  private string? proxy_address;
  private string? proxy_port;
  private string? proxy_username;
  private string? proxy_password;

  private GLib.File? local_recipe;
  private string root_url = "https://repo.aosc.io";

  private uint? progressbar_installation_event_source_id;

  /**
   * Constructor for ``Dk.Gui.Main``.
   */
  public Main() {
    /* Load CSS from resource to override styles of some widgets */
    var css_provider = new Gtk.CssProvider();
    css_provider.load_from_resource("/io/aosc/DeployKit/ui/gui.css");
    Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    /* The default locale is the current locale */
    this.entry_recipe_general_locale.set_placeholder_text(GLib.Intl.setlocale());
    this.entry_recipe_expert_locale.set_placeholder_text(GLib.Intl.setlocale());
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Preparing".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_prepare_map_cb() {
    this.headerbar_main.set_title(_("Preparing"));
    this.togglebtn_expert.set_visible(false);
    this.btn_back.set_visible(false);
    this.btn_network.set_visible(true);
    this.btn_ok.set_visible(false);

    /*
     * If a recipe.json is given, use that file and do not fetch from the
     * Internet. This is useful for debugging.
     */
    if (this.local_recipe != null) {
      GLib.message(_("You are using a local recipe. This is only for debugging and advanced users' use; DO NOT USE IT if you don't know what you are doing!"));

      uint8[] file_content;
      try {
        this.local_recipe.load_contents(null, out file_content, null);
      } catch (Error e) {
        this.dialog(_("%s.\n\nPlease check again if the file is accessible."), e.message);
        GLib.Process.exit(2);
      }

      /*
       * Load recipe from the specified file.
       */
      try {
        this.load_recipe((string)file_content);
      } catch (LoadRecipeError e) {
        this.dialog(
          _("Failed to load the specified recipe at %s: %s\n\nPlease check again if the content of file is valid."),
          this.local_recipe.get_parse_name(),
          e.message
        );
        GLib.Process.exit(1);
      }

      /* Also load destinations (the list of disks) */
      try {
        this.load_disks();
      } catch (LoadDisksError e) {
        this.dialog(
          _("Failed to probe disks on the machine: %s\n\nPlease report this incident to us."),
          e.message
        );
        GLib.Process.exit(1);
      }

      /* Switch to the recipe (general) page. */
      this.stack_main.set_visible_child(this.box_recipe_general);

      return;
    }

    /*
     * If no local recipe is given, fetch one online.
     *
     * After the thread below is created, the signal handler returns. When
     * data arrives the thread will tell GLib to call a lambda function in the
     * main thread to update GUI (to switch to the recipe page).
     */
    new GLib.Thread<bool>("fetch_recipe", () => {
      var session = new Soup.Session();
      var baseuri = new Soup.URI(this.root_url);
      var httpuri = new Soup.URI.with_base(baseuri, "/aosc-os/recipe.json");
      var httpmsg = new Soup.Message.from_uri("GET", httpuri);

      var status = session.send_message(httpmsg);

      if (status != Soup.Status.OK) {
        GLib.Idle.add(() => {
          /* TODO: Service unavailable, switch to offline mode */

          /* But also load destinations (the list of disks) */
          try {
            this.load_disks();
          } catch (LoadDisksError e) {
            this.dialog(
              _("Failed to probe disks on the machine: %s\n\nPlease report this incident to us."),
              e.message
            );
            GLib.Process.exit(1);
          }

          /* Switch to the recipe (general) page. */
          this.stack_main.set_visible_child(this.box_recipe_general);

          /* Give a message to the user about what happened */
          this.dialog(
            _("You are now in offline mode because it looks like the service is temporary unavailable (error code %u).\n\nPlease check your network connection. If necessary, use the provided network settings, and try again. If you believe that your network connection has nothing wrong, then we might get something wrong. Please report to us."),
            status
          );
          return false;
        });

        /* Don't continue execution */
        return false;
      }

      /* Parse the returned content to a recipe */
      var http_content = (string)httpmsg.response_body.data;

      /* Once fetched, go back to the main thread to refresh GUI */
      GLib.Idle.add(() => {
        /*
         * All processes above successfully finished, enter online mode.
         */
        try {
          this.load_recipe(http_content);
        } catch (LoadRecipeError e) {
          this.dialog(
            _("Failed to load the fetched recipe: %s\n\nPlease report this incident to us."),
            e.message
          );
          GLib.Process.exit(1);
        }

        /* Also load destinations (the list of disks) */
        try {
          this.load_disks();
        } catch (LoadDisksError e) {
          this.dialog(
            _("Failed to probe disks on the machine: %s\n\nPlease report this incident to us."),
            e.message
          );
          GLib.Process.exit(1);
        }

        /* Switch to the recipe (general) page. */
        this.stack_main.set_visible_child(this.box_recipe_general);

        /* Tell GLib not to call the function again. */
        return false;
      });

      return true;
    });
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Recipe (General)".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_recipe_general_map_cb() {
    this.headerbar_main.set_title(_("Recipe"));
    this.togglebtn_expert.set_visible(true);
    this.btn_back.set_visible(false);
    this.btn_network.set_visible(true);
    this.btn_ok.set_visible(true);
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Recipe (Expert)".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_recipe_expert_map_cb() {
    this.headerbar_main.set_title(_("Recipe"));
    this.togglebtn_expert.set_visible(true);
    this.btn_back.set_visible(false);
    this.btn_network.set_visible(true);
    this.btn_ok.set_visible(true);
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Confirm".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_confirm_map_cb() {
    this.headerbar_main.set_title(_("Confirm"));
    this.togglebtn_expert.set_visible(false);
    this.btn_back.set_visible(true);
    this.btn_network.set_visible(true);
    this.btn_ok.set_visible(true);

    /* Collect recipe and display information for the user to confirm */
    Gtk.ListBoxRow? variant_row = null;
    Gtk.ListBoxRow? dest_row = null;
    Gtk.ListBoxRow? mirror_row = null;
    Gtk.ListBoxRow? xcomps_row = null;

    if (this.last_page == box_recipe_general) {
      variant_row = this.listbox_recipe_general_variant.get_selected_row();
      dest_row    = this.listbox_recipe_general_dest.get_selected_row();
      mirror_row  = this.listbox_recipe_general_mirror.get_selected_row();
      xcomps_row  = this.listbox_recipe_general_xcomps.get_selected_row();
    } else if (this.last_page == box_recipe_expert) {
      variant_row = this.listbox_recipe_expert_biy.get_selected_row();
      dest_row    = this.listbox_recipe_expert_dest.get_selected_row();
      mirror_row  = this.listbox_recipe_expert_mirror.get_selected_row();
      xcomps_row  = this.listbox_recipe_expert_xcomps.get_selected_row();
    }

    string hostname = this.entrybuffer_hostname.get_text();
    string locale   = this.entrybuffer_locale.get_text();
    string username = this.entrybuffer_admin_username.get_text();

    this.label_confirm_variant.set_text(
      variant_row == null ?
      _("Not selected") :
      (variant_row.get_child() as Rows.Variant).get_variant_name()
    );

    this.label_confirm_dest.set_text(
      dest_row == null ?
      _("Not selected") :
      (dest_row.get_child() as Rows.Destination).get_destination_path()
    );

    this.label_confirm_mirror.set_text(
      mirror_row == null ?
      _("Not selected") :
      (mirror_row.get_child() as Rows.Mirror).get_mirror_name()
    );

    this.label_confirm_xcomps.set_text(
      xcomps_row == null ?
      _("Not selected") :
      (xcomps_row.get_child() as Rows.ExtraComponent).get_component_name()
    );

    this.label_confirm_hostname.set_text(
      (hostname == null || hostname == "") ? _("Not set") : hostname
    );

    this.label_confirm_locale.set_text(
      (locale == null || locale == "") ? GLib.Intl.setlocale() : locale
    );

    this.label_confirm_admin_username.set_text(
      (username == null || username == "") ? _("Not set") : username
    );

    /* Some fields are mandatory; disable the OK button if they are not set */
    if (variant_row == null) {
      this.label_confirm_info_missing_prompt.set_visible(true);
      this.btn_ok.set_sensitive(false);
    } else if (dest_row == null) {
      this.label_confirm_info_missing_prompt.set_visible(true);
      this.btn_ok.set_sensitive(false);
    } else if (hostname == null || hostname == "") {
      this.label_confirm_info_missing_prompt.set_visible(true);
      this.btn_ok.set_sensitive(false);
    } else if (username == null || username == "") {
      this.label_confirm_info_missing_prompt.set_visible(true);
      this.btn_ok.set_sensitive(false);
    } else {
      /* Otherwise */
      this.label_confirm_info_missing_prompt.set_visible(false);
      this.btn_ok.set_sensitive(true);
    }
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Installing".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_install_map_cb() {
    this.headerbar_main.set_title(_("Installing"));
    this.togglebtn_expert.set_visible(false);
    this.btn_back.set_visible(false);
    this.btn_network.set_visible(false);
    this.btn_ok.set_visible(false);
  }

  /**
   * Callback on ``map`` event of ``Gtk.Box`` "Done".
   *
   * This function is called as the box shows up, so as to switch the content
   * in the header bar correspondingly.
   */
  [GtkCallback]
  private void box_done_map_cb() {
    this.headerbar_main.set_title(_("Installing"));
    this.togglebtn_expert.set_visible(false);
    this.btn_back.set_visible(false);
    this.btn_network.set_visible(false);
    this.btn_ok.set_visible(false);
  }

  /**
   * Callback on ``toggled`` event of the toggle-button "Expert".
   *
   * When the button is toggled, the interface should switch to the "expert"
   * recipe for the user to perform advanced installation.
   */
  [GtkCallback]
  private void togglebtn_expert_toggled_cb() {
    if (this.togglebtn_expert.get_active())
      this.stack_main.set_visible_child(this.box_recipe_expert);
    else
      this.stack_main.set_visible_child(this.box_recipe_general);
  }

  /**
   * Callback on ``clicked`` event of the button "Back".
   *
   * When the button is clicked, the interface should switch back to the last
   * page.
   */
  [GtkCallback]
  private void btn_back_clicked_cb() {
    if (this.last_page != null)
      this.stack_main.set_visible_child(this.last_page);

    /*
     * And since box_confirm_map_cb will set btn_ok to insensitive we revert
     * it here
     */
    this.btn_ok.set_sensitive(true);
  }

  /**
   * Callback on ``clicked`` event of the button "OK".
   *
   * When the button is clicked, installation should take place according to
   * what the user selects in the recipe.
   */
  [GtkCallback]
  private void btn_ok_clicked_cb() {
    var visible_child = this.stack_main.get_visible_child();
    if (visible_child == this.box_recipe_general ||
        visible_child == this.box_recipe_expert)
    {
      /* Remember which recipe the user used */
      this.last_page = visible_child;

      this.stack_main.set_visible_child(this.box_confirm);
    } else if (visible_child == this.box_confirm) {
      // TODO: Proceed with installation
      // 1. Store configuration into config store
      // 2. Switch to installation page
      // 3. Spawn IR generator to create config for the backend
      // 4. Spawn the backend, bind status RPC messages to widgets
      this.label_installation_step_curr.set_text("1");
      this.label_installation_step_max.set_text("8");
      this.label_installation_step_desc.set_text("Preparing for installation");
      this.stack_main.set_visible_child(this.box_install);
    } else {
      // The button is unexpectedly clicked when it should not be shown
    }
  }

  /**
   * Callback on ``clicked`` event of button "Network Config".
   *
   * When the button is clicked, a network configuation dialog should show up
   * for the user to configure their suitable network setup, e.g. proxies, or
   * offline.
   */
  [GtkCallback]
  private void btn_network_clicked_cb() {
    var network_config_dialog = new Dk.Gui.NetworkConfig(
      this.proxy_type,
      this.proxy_address,
      this.proxy_port,
      this.proxy_username,
      this.proxy_password,
      (type, addr, port, username, password) => {
        this.proxy_type     = type;
        this.proxy_address  = addr;
        this.proxy_port     = port;
        this.proxy_username = username;
        this.proxy_password = password;

        /* Highlight the button to indicate that the proxy has been set */
        var ctx = this.btn_network.get_style_context();

        if (this.proxy_type != ProxyType.DISABLE &&
            this.proxy_address != null &&
            this.proxy_port != null)
        {
          ctx.add_class("suggested-action");
        } else {
          if (ctx.has_class("suggested-action")) {
            ctx.remove_class("suggested-action");
          }
        }
      }
    );

    /* Set modal dialog transient for the main window */
    network_config_dialog.set_transient_for(this);
    network_config_dialog.show_all();
  }

  /**
   * Callback on ``response`` event of the bulletin banner.
   *
   * @param response_id The GTK response ID set in GUI definition.
   */
  [GtkCallback]
  private void infobar_bulletin_response_cb(int response_id) {
    if (response_id == Gtk.ResponseType.CANCEL ||
        response_id == Gtk.ResponseType.CLOSE)
    {
      /*
        * Either the close button is clicked or Esc is pressed.
        *
        * I still don't know why after GtkInfoBar reveals itself, there is
        * still an annoying 1px line displaying. Look how nice a GtkRevealer
        * does.
        */
      this.revealer_bulletin.set_reveal_child(false);
    }
  }

  [GtkCallback]
  private void btn_recipe_general_variant_clear_clicked_cb() {
    this.listbox_recipe_general_variant.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_general_dest_clear_clicked_cb() {
    this.listbox_recipe_general_dest.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_general_mirror_clear_clicked_cb() {
    this.listbox_recipe_general_mirror.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_general_xcomps_clear_clicked_cb() {
    this.listbox_recipe_general_xcomps.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_expert_biy_clear_clicked_cb() {
    this.listbox_recipe_expert_biy.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_expert_xcomps_clear_clicked_cb() {
    this.listbox_recipe_expert_xcomps.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_expert_dest_clear_clicked_cb() {
    this.listbox_recipe_expert_dest.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_expert_mirror_clear_clicked_cb() {
    this.listbox_recipe_expert_mirror.unselect_all();
  }

  [GtkCallback]
  private void btn_recipe_x_dest_refresh_clicked_cb() {
    try {
      this.load_disks();
    } catch (LoadDisksError e) {
      this.dialog(
        _("Failed to probe disks on the machine: %s\n\nPlease report this incident to us."),
        e.message
      );
    }
  }

  [GtkCallback]
  private void btn_recipe_x_dest_partition_clicked_cb() {
    try {
      /* We don't care the status of GParted */
      new Subprocess(SubprocessFlags.NONE, "gparted", null);
    } catch (Error e) {
      this.dialog(
        _("Failed to execute GParted: %s.\n\nPlease check if GParted is installed correctly on your computer. If you believe that you have done nothing wrong, please report this incident to us."),
        e.message
      );
    }
  }

  [GtkCallback]
  private void btn_recipe_expert_biy_add_clicked_cb() {
    var chooser = new Gtk.FileChooserNative(_("Select a Custom Tarball"), this, Gtk.FileChooserAction.OPEN, null, null);
    chooser.set_modal(true);
    int r = chooser.run();

    if (r != Gtk.ResponseType.ACCEPT)
      return;

    File tarball = chooser.get_file();
    FileInfo? info = null;
    try {
      info = tarball.query_info(
        "standard::symbolic-icon,standard::display-name,standard::size,time::modified",
        FileQueryInfoFlags.NONE
      );
    } catch (Error e) {
      this.dialog(
        _("Cannot retrieve information about the file you chose: %s.\n\nYou may not add this file as your custom variant."),
        e.message
      );

      return;
    }

    Icon icon = info.get_symbolic_icon();
    string? icon_name = (icon is ThemedIcon) ? (icon as ThemedIcon).get_names()[0] : null;
    string file_name = info.get_display_name();
    int64 size = info.get_size();
    DateTime? modtime = info.get_modification_date_time();

    this.listbox_recipe_expert_biy.add(
      new Rows.Variant(
        icon_name ?? "package-x-generic-symbolic",
        file_name,
        modtime ?? new DateTime.now_local(),
        size,
        -1 /* Unknown */
      )
    );

    chooser.destroy();
  }

  [GtkCallback]
  private void btn_recipe_expert_mirror_add_clicked_cb() {
    /* Insert a custom mirror row into the mirror list */
    this.listbox_recipe_expert_mirror.add(new Rows.MirrorCustom());
  }

  /**
   * Check if the root password entry on the current page match with the retyped
   * one.
   */
  [GtkCallback]
  private void entry_recipe_x_root_passwords_changed_cb() {
    string root_password_a = this.entrybuffer_root_password.get_text();
    string root_password_b = this.entrybuffer_root_password_retype.get_text();
    Gtk.StyleContext? ctx = null;

    if (this.stack_main.get_visible_child() == this.box_recipe_general) {
      ctx = this.entry_recipe_general_root_password_retype.get_style_context();
    } else if (this.stack_main.get_visible_child() == this.box_recipe_expert) {
      ctx = this.entry_recipe_expert_root_password_retype.get_style_context();
    } else {
      /* Something happened */
      return;
    }

    if (root_password_a != root_password_b) {
      /* Set the entry to red and prevent the user from proceeding */
      ctx.add_class("dk-invalid-password");
      this.btn_ok.set_sensitive(false);
    } else {
      if (ctx.has_class("dk-invalid-password")) {
        ctx.remove_class("dk-invalid-password");
      }
      this.btn_ok.set_sensitive(true);
    }
  }

  /**
   * Check if the administrator password entry on the current page match with
   * the retyped one.
   */
  [GtkCallback]
  private void entry_recipe_x_admin_passwords_changed_cb() {
    string admin_password_a = this.entrybuffer_admin_password.get_text();
    string admin_password_b = this.entrybuffer_admin_password_retype.get_text();
    Gtk.StyleContext? ctx = null;

    if (this.stack_main.get_visible_child() == this.box_recipe_general) {
      ctx = this.entry_recipe_general_admin_password_retype.get_style_context();
    } else if (this.stack_main.get_visible_child() == this.box_recipe_expert) {
      ctx = this.entry_recipe_expert_admin_password_retype.get_style_context();
    } else {
      /* Something happened */
      return;
    }

    if (admin_password_a != admin_password_b) {
      /* Set the entry to red and prevent the user from proceeding */
      ctx.add_class("dk-invalid-password");
      this.btn_ok.set_sensitive(false);
    } else {
      if (ctx.has_class("dk-invalid-password")) {
        ctx.remove_class("dk-invalid-password");
      }
      this.btn_ok.set_sensitive(true);
    }
  }

  /**
   * Load a recipe.json string into GUI.
   *
   * @param recipe_str A JSON string representing a recipe object.
   */
  private void load_recipe(string recipe_str) throws LoadRecipeError {
    var recipe = new Dk.Recipe.Recipe();
    bool r = recipe.from_json_string(recipe_str);
    if (!r)
      throw new LoadRecipeError.PARSE_ERROR(_("The recipe is invalid and cannot be parsed."));

    /* NOTE: Parsing version 0 recipe. */
    if (recipe.get_version() != 0)
      throw new LoadRecipeError.UNKNOWN_VERSION(_("Recipe version %d is not supported."), recipe.get_version());

    /* Bulletin */
    var bulletin = recipe.get_bulletin();
    if (bulletin.get_bulletin_type() != "unknown" &&
        bulletin.get_bulletin_type() != "none")
    {
      var title = bulletin.get_title_l10n(Utils.get_lang()) ?? bulletin.get_title();
      var body  = bulletin.get_body_l10n(Utils.get_lang()) ?? bulletin.get_body();

      if (title != null)
        this.label_bulletin_title.set_text(title);
      if (body != null)
        this.label_bulletin_body.set_text(body);

      /* Reveal only when something is to be shown */
      if (!(title == null && body == null))
        this.revealer_bulletin.set_reveal_child(true);
    }

    /* Variants */
    recipe.get_variants().foreach((v) => {
      /* XXX: Only the newest tarball is shown. */
      var tarball_newest = v.get_tarball_newest();

      /*
       * NOTE: It is impossible to add a same widget to two different
       * containers, so for the two different recipe pages, two identical
       * "Variant" rows are allocated.
       */
      this.listbox_recipe_general_variant.add(
        new Rows.Variant(
          "package-x-generic-symbolic",
          v.get_name_l10n(Dk.Utils.get_lang()) ?? v.get_name(),
          tarball_newest.get_date(),
          tarball_newest.get_download_size(),
          tarball_newest.get_installation_size()
        )
      );
      this.listbox_recipe_expert_biy.add(
        new Rows.Variant(
          "package-x-generic-symbolic",
          v.get_name_l10n(Dk.Utils.get_lang()) ?? v.get_name(),
          tarball_newest.get_date(),
          tarball_newest.get_download_size(),
          tarball_newest.get_installation_size()
        )
      );

      return true;
    });

    /* Mirrors */
    recipe.get_mirrors().foreach((m) => {
      this.listbox_recipe_general_mirror.add(
        new Rows.Mirror(
          "package-x-generic-symbolic",
          m.get_name_l10n(Dk.Utils.get_lang()) ?? m.get_name(),
          m.get_location_l10n(Dk.Utils.get_lang()) ?? m.get_location(),
          m.get_url()
        )
      );
      this.listbox_recipe_expert_mirror.add(
        new Rows.Mirror(
          "package-x-generic-symbolic",
          m.get_name_l10n(Dk.Utils.get_lang()) ?? m.get_name(),
          m.get_location_l10n(Dk.Utils.get_lang()) ?? m.get_location(),
          m.get_url()
        )
      );

      return true;
    });

    /* TODO: Extra Components */
  }

  /**
   * Load disk information (i.e. the Destination section) onto the GUI.
   */
  private void load_disks() throws LoadDisksError {
    UDisks.Client? client = null;
    try {
      client = new UDisks.Client.sync();
    } catch (Error e) {
      throw new LoadDisksError.CONNECTION_ERROR(_("Cannot connect to the UDisks2 daemon via DBus."));
    }

    /* Clear list boxes (I find it very efficient) */
    this.listbox_recipe_general_dest.bind_model(null, null);
    this.listbox_recipe_expert_dest.bind_model(null, null);

    /* Retrieve all objects managed by UDisks */
    List<DBusObject> udobjs = client.get_object_manager().get_objects();

    /* This list from GLib.Drive is for icon retrieval (see below) */
    List<GLib.Drive> gdrives = GLib.VolumeMonitor.get().get_connected_drives();

    /* These are used for sorting the results before adding onto the GUI */
    var destrows_general = new List<Rows.Destination>();
    var destrows_expert = new List<Rows.Destination>();

    /*
     * We now do the following things:
     *
     * - Iterate over the objects managed by UDisks to get partition information.
     * - For every partition, also gets the icon name from GLib, since UDisks do
     *   not provide such information (an empty string is returned)...
     */
    udobjs.foreach((o) => {
      UDisks.Object obj = o as UDisks.Object;

      UDisks.Block? block = obj.get_block();
      UDisks.Partition? part = obj.get_partition();

      if (block == null || part == null)
        return;

      UDisks.Drive? drive = client.get_drive_for_block(block);
      if (drive == null)
        return;

      assert(drive != null);

      string device = block.device;
      string model = drive.model;
      uint64 partsize = part.size;

      /* Then we also iterate over the GLib.Drive list for icons */
      gdrives.foreach((gdrive) => {
        /* XXX: is this correct? */
        if (!device.has_prefix(gdrive.get_identifier(GLib.DRIVE_IDENTIFIER_KIND_UNIX_DEVICE)))
          return;

        var icon = gdrive.get_symbolic_icon() as GLib.ThemedIcon;

        destrows_general.append(
          new Rows.Destination(
            icon.get_names()[0],
            device,
            _("On ") + model,
            (int64)partsize
          )
        );
        destrows_expert.append(
          new Rows.Destination(
            icon.get_names()[0],
            device,
            _("On ") + model,
            (int64)partsize
          )
        );
      });
    });

    /* Sort the results according to the device names */
    destrows_general.sort((a, b) => {
      string a_dev = a.get_destination_path();
      string b_dev = b.get_destination_path();

      if (a_dev > b_dev)
        return 1;
      else if (a_dev < b_dev)
        return -1;
      else
        return 0;
    });
    destrows_expert.sort((a, b) => {
      string a_dev = a.get_destination_path();
      string b_dev = b.get_destination_path();

      if (a_dev > b_dev)
        return 1;
      else if (a_dev < b_dev)
        return -1;
      else
        return 0;
    });

    /* Then add them onto the GUI */
    destrows_general.foreach((row) => this.listbox_recipe_general_dest.add(row));
    destrows_expert.foreach((row) => this.listbox_recipe_expert_dest.add(row));
  }

  /**
   * Set the current step number and description in the installation page.
   *
   * @param step The current step number.
   * @param desc A description describing the current step.
   */
  private void step(int step, string desc) {
    this.label_installation_step_curr.set_text(@"$step");
    this.label_installation_step_desc.set_text(desc);
  }

  /**
   * Set the maximum step number in the installation page.
   *
   * Note that this does not prevent the current step number from exceeding this
   * maximum number; this is only for updating the GUI.
   *
   * @param max_steps The maximum step number.
   */
  private void set_max_steps(int max_steps) {
    this.label_installation_step_max.set_text(@"$max_steps");
  }

  /**
   * Show "of Y" in "Step X in Y" on the installation page.
   */
  private void show_max_steps() {
    this.label_installation_step_of.set_visible(true);
    this.label_installation_step_max.set_visible(true);
  }

  /**
   * Hide "of Y" in "Step X in Y" on the installation page.
   *
   * This is useful when the maximum step is unknown.
   */
  private void hide_max_steps() {
    this.label_installation_step_of.set_visible(false);
    this.label_installation_step_max.set_visible(false);
  }

  /**
   * Set the progress bar on the installation page.
   *
   * @param percent The percent of the progress bar (between 0 and 100). The
   *                special value -1 pulses the progress bar.
   */
  private void progress(int percent)
    requires (percent >= -1 && percent <= 100)
  {
    if (this.progressbar_installation_event_source_id != null) {
      GLib.Source.remove(this.progressbar_installation_event_source_id);
      this.progressbar_installation_event_source_id = null;
    }

    if (percent >= 0) {
      this.progressbar_installation.set_text(null);
      this.progressbar_installation.set_fraction(percent / 100.0);
    } else {
      this.progressbar_installation.set_text(_("Skating…"));
      this.progressbar_installation_event_source_id = GLib.Timeout.add(300, () => {
        this.progressbar_installation.pulse();
        return true;
      });
    }
  }

  /**
   * Pop up a message dialog to prompt the user about things happening.
   */
  private void dialog(string format, ...) {
    var dlg = new Gtk.MessageDialog(
      this,
      Gtk.DialogFlags.DESTROY_WITH_PARENT
        | Gtk.DialogFlags.MODAL
        | Gtk.DialogFlags.USE_HEADER_BAR,
      Gtk.MessageType.ERROR,
      Gtk.ButtonsType.OK,
      format.vprintf(va_list())
    );

    dlg.run();
    dlg.destroy();
  }

  public GLib.File get_local_recipe() {
    return this.local_recipe;
  }

  public void set_local_recipe(GLib.File recipe) {
    this.local_recipe = recipe;
  }

  public string get_root_url() {
    return this.root_url;
  }

  public void set_root_url(string url) {
    this.root_url = url;
  }
}

} /* namespace Gui */
} /* namespace Dk */

#include <gtk/gtk.h>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <filesystem>

// ─── Data types ─────────────────────────────────────────────────────────────

enum class Category {
    Media,
    Screenshot,
    Applications,
    WindowManagement,
    Focus,
    Movement,
    Workspaces,
    Monitors,
    Layout,
    System,
};

struct Keybinding {
    std::vector<std::string> modifiers;
    std::string key;
    std::string function;
    std::string description;
    Category category;
};

static const char* category_name(Category c) {
    switch (c) {
        case Category::Media:            return "Media Controls";
        case Category::Screenshot:       return "Screenshots";
        case Category::Applications:     return "Applications";
        case Category::WindowManagement: return "Window Management";
        case Category::Focus:            return "Window Focus";
        case Category::Movement:         return "Window Movement";
        case Category::Workspaces:       return "Workspaces";
        case Category::Monitors:         return "Monitors";
        case Category::Layout:           return "Layout & Sizing";
        case Category::System:           return "System";
    }
    return "";
}

static const char* category_color(Category c) {
    switch (c) {
        case Category::Media:            return "#f7768e";
        case Category::Screenshot:       return "#ff9e64";
        case Category::Applications:     return "#e0af68";
        case Category::WindowManagement: return "#89aa61";
        case Category::Focus:            return "#80cbc4";
        case Category::Movement:         return "#516c93";
        case Category::Workspaces:       return "#b153a7";
        case Category::Monitors:         return "#ad401f";
        case Category::Layout:           return "#14a57c";
        case Category::System:           return "#ff9e64";
    }
    return "#e0d6c8";
}

static const char* category_css_class(Category c) {
    switch (c) {
        case Category::Media:            return "cat-media";
        case Category::Screenshot:       return "cat-screenshot";
        case Category::Applications:     return "cat-applications";
        case Category::WindowManagement: return "cat-windowmgmt";
        case Category::Focus:            return "cat-focus";
        case Category::Movement:         return "cat-movement";
        case Category::Workspaces:       return "cat-workspaces";
        case Category::Monitors:         return "cat-monitors";
        case Category::Layout:           return "cat-layout";
        case Category::System:           return "cat-system";
    }
    return "";
}

// ─── Keybinding data ────────────────────────────────────────────────────────

static std::vector<Keybinding> get_keybindings() {
    return {
        // Media Controls
        {{}, "XF86AudioRaiseVolume", "Volume Up", "Increase volume (volume.sh)", Category::Media},
        {{}, "XF86AudioLowerVolume", "Volume Down", "Decrease volume (volume.sh)", Category::Media},
        {{}, "XF86AudioMute", "Mute Toggle", "Toggle audio mute (volume.sh)", Category::Media},
        {{}, "XF86AudioMicMute", "Mic Mute", "Toggle microphone mute (volume.sh)", Category::Media},
        {{}, "XF86MonBrightnessUp", "Brightness Up", "Increase screen brightness", Category::Media},
        {{}, "XF86MonBrightnessDown", "Brightness Down", "Decrease screen brightness", Category::Media},
        {{}, "XF86AudioPlay", "Play/Pause", "Toggle media playback (playerctl)", Category::Media},
        {{}, "XF86AudioPause", "Pause", "Pause media playback (playerctl)", Category::Media},
        {{}, "XF86AudioNext", "Next Track", "Skip to next track (playerctl)", Category::Media},
        {{}, "XF86AudioPrev", "Previous Track", "Go to previous track (playerctl)", Category::Media},
        {{}, "XF86AudioStop", "Stop", "Stop media playback (playerctl)", Category::Media},

        // Screenshots
        {{"Super", "Shift"}, "s", "Screenshot", "Take screenshot (~/.config/mango/screenshot.sh)", Category::Screenshot},

        // Applications
        {{"Super"}, "Return", "Terminal", "Launch Alacritty terminal", Category::Applications},
        {{"Super", "Shift"}, "Return", "Terminal + Tmux", "Launch Alacritty with tmux", Category::Applications},
        {{"Super"}, "d", "App Launcher", "Launch rofi (drun)", Category::Applications},
        {{"Super", "Shift"}, "d", "Run Launcher", "Launch rofi (run)", Category::Applications},
        {{"Super", "Alt"}, "d", "Wmenu Run", "Launch wmenu-run", Category::Applications},
        {{"Super"}, "e", "Editor", "Launch Alacritty with nvim", Category::Applications},
        {{"Super", "Shift"}, "e", "File Manager", "Launch Thunar file manager", Category::Applications},
        {{"Super"}, "b", "Browser", "Launch Zen browser", Category::Applications},
        {{"Super"}, "p", "Notepad", "Open notepad in nvim", Category::Applications},
        {{"Super"}, "v", "Clipboard", "Clipboard history via rofi (cliphist)", Category::Applications},
        {{"Super", "Shift"}, "v", "Clapboard", "Open clapboard clipboard manager", Category::Applications},
        {{"Super"}, "n", "Notifications", "Toggle notification center (swaync)", Category::Applications},
        {{"Super", "Shift"}, "n", "Night Light", "Toggle blue light filter (hyprshade)", Category::Applications},
        {{"Super", "Shift"}, "c", "Volume Control", "Open pavucontrol", Category::Applications},
        {{"Super"}, "x", "Logout Menu", "Open wlogout power menu", Category::Applications},

        // Window Management
        {{"Super"}, "c", "Close Window", "Kill the focused client", Category::WindowManagement},
        {{"Super"}, "f", "Toggle Floating", "Toggle floating mode for focused window", Category::WindowManagement},
        {{"Super", "Shift"}, "f", "Toggle Fullscreen", "Toggle fullscreen for focused window", Category::WindowManagement},
        {{"Super"}, "a", "Toggle Maximize", "Toggle maximize screen", Category::WindowManagement},
        {{"Super"}, "g", "Toggle Global", "Toggle global window", Category::WindowManagement},
        {{"Alt"}, "Tab", "Toggle Overview", "Toggle overview mode", Category::WindowManagement},
        {{"Super"}, "i", "Minimize", "Minimize the focused window", Category::WindowManagement},
        {{"Super", "Shift"}, "i", "Restore Minimized", "Restore last minimized window", Category::WindowManagement},
        {{"Super"}, "o", "Toggle Overlay", "Toggle window overlay", Category::WindowManagement},
        {{"Super"}, "s", "Scratchpad", "Toggle scratchpad", Category::WindowManagement},
        {{"Super", "Alt"}, "s", "Scratchpad Alt", "Toggle scratchpad (alternative)", Category::WindowManagement},

        // Focus Controls
        {{"Super"}, "Tab", "Focus Next", "Focus next window in stack", Category::Focus},
        {{"Super"}, "h", "Focus Left", "Focus direction left (Vi)", Category::Focus},
        {{"Super"}, "j", "Focus Down", "Focus direction down (Vi)", Category::Focus},
        {{"Super"}, "k", "Focus Up", "Focus direction up (Vi)", Category::Focus},
        {{"Super"}, "l", "Focus Right", "Focus direction right (Vi)", Category::Focus},
        {{"Super"}, "Left", "Focus Left", "Focus direction left (Arrow)", Category::Focus},
        {{"Super"}, "Right", "Focus Right", "Focus direction right (Arrow)", Category::Focus},
        {{"Super"}, "Up", "Focus Up", "Focus direction up (Arrow)", Category::Focus},
        {{"Super"}, "Down", "Focus Down", "Focus direction down (Arrow)", Category::Focus},

        // Window Movement
        {{"Super", "Shift"}, "h", "Swap Left", "Exchange client left (Vi)", Category::Movement},
        {{"Super", "Shift"}, "j", "Swap Down", "Exchange client down (Vi)", Category::Movement},
        {{"Super", "Shift"}, "k", "Swap Up", "Exchange client up (Vi)", Category::Movement},
        {{"Super", "Shift"}, "l", "Swap Right", "Exchange client right (Vi)", Category::Movement},
        {{"Super", "Shift", "Ctrl"}, "Left", "Swap Left", "Exchange client left (Arrow)", Category::Movement},
        {{"Super", "Shift", "Ctrl"}, "Right", "Swap Right", "Exchange client right (Arrow)", Category::Movement},
        {{"Super", "Shift", "Ctrl"}, "Up", "Swap Up", "Exchange client up (Arrow)", Category::Movement},
        {{"Super", "Shift", "Ctrl"}, "Down", "Swap Down", "Exchange client down (Arrow)", Category::Movement},
        {{"Super", "Shift"}, "1", "Move to Tag 1", "Move window to tag 1 (silent)", Category::Movement},
        {{"Super", "Shift"}, "2", "Move to Tag 2", "Move window to tag 2 (silent)", Category::Movement},
        {{"Super", "Shift"}, "3", "Move to Tag 3", "Move window to tag 3 (silent)", Category::Movement},
        {{"Super", "Shift"}, "4", "Move to Tag 4", "Move window to tag 4 (silent)", Category::Movement},
        {{"Super", "Shift"}, "5", "Move to Tag 5", "Move window to tag 5 (silent)", Category::Movement},
        {{"Super", "Shift"}, "6", "Move to Tag 6", "Move window to tag 6 (silent)", Category::Movement},
        {{"Super", "Shift"}, "7", "Move to Tag 7", "Move window to tag 7 (silent)", Category::Movement},
        {{"Super", "Shift"}, "8", "Move to Tag 8", "Move window to tag 8 (silent)", Category::Movement},
        {{"Super", "Shift"}, "9", "Move to Tag 9", "Move window to tag 9 (silent)", Category::Movement},
        {{"Ctrl", "Super"}, "Left", "Move Tag Left", "Move window to tag left", Category::Movement},
        {{"Ctrl", "Super"}, "Right", "Move Tag Right", "Move window to tag right", Category::Movement},

        // Workspaces / Tags
        {{"Super"}, "1", "Tag 1", "View tag 1", Category::Workspaces},
        {{"Super"}, "2", "Tag 2", "View tag 2", Category::Workspaces},
        {{"Super"}, "3", "Tag 3", "View tag 3", Category::Workspaces},
        {{"Super"}, "4", "Tag 4", "View tag 4", Category::Workspaces},
        {{"Super"}, "5", "Tag 5", "View tag 5", Category::Workspaces},
        {{"Super"}, "6", "Tag 6", "View tag 6", Category::Workspaces},
        {{"Super"}, "7", "Tag 7", "View tag 7", Category::Workspaces},
        {{"Super"}, "8", "Tag 8", "View tag 8", Category::Workspaces},
        {{"Super"}, "9", "Tag 9", "View tag 9", Category::Workspaces},
        {{"Super", "Ctrl"}, "Right", "View Tag Right", "View next tag to the right", Category::Workspaces},
        {{"Super", "Ctrl"}, "Left", "View Tag Left", "View next tag to the left", Category::Workspaces},

        // Monitors
        {{"Alt", "Shift"}, "Left", "Focus Monitor Left", "Focus monitor to the left", Category::Monitors},
        {{"Alt", "Shift"}, "Right", "Focus Monitor Right", "Focus monitor to the right", Category::Monitors},
        {{"Super", "Alt"}, "Left", "Move to Monitor Left", "Move window to left monitor", Category::Monitors},
        {{"Super", "Alt"}, "Right", "Move to Monitor Right", "Move window to right monitor", Category::Monitors},

        // Layout & Sizing
        {{"Super", "Shift"}, "Right", "Resize Right", "Resize window wider (+30)", Category::Layout},
        {{"Super", "Shift"}, "Left", "Resize Left", "Resize window narrower (-30)", Category::Layout},
        {{"Super", "Shift"}, "Up", "Resize Up", "Resize window shorter (-30)", Category::Layout},
        {{"Super", "Shift"}, "Down", "Resize Down", "Resize window taller (+30)", Category::Layout},
        {{"Alt"}, "e", "Set Proportion Full", "Set scroller proportion to 1.0", Category::Layout},
        {{"Alt"}, "x", "Switch Proportion", "Switch scroller proportion preset", Category::Layout},
        {{"Super", "Alt"}, "n", "Switch Layout", "Switch to next layout", Category::Layout},
        {{"Alt", "Shift"}, "x", "Increase Gaps", "Increase gaps by 1", Category::Layout},
        {{"Alt", "Shift"}, "z", "Decrease Gaps", "Decrease gaps by 1", Category::Layout},
        {{"Alt", "Shift"}, "r", "Toggle Gaps", "Toggle gaps on/off", Category::Layout},

        // System
        {{"Super", "Alt"}, "l", "Lock Screen", "Lock the screen (hyprlock)", Category::System},
        {{"Super"}, "Delete", "Quit", "Quit mango compositor", Category::System},
        {{"Ctrl", "Shift"}, "r", "Reload Config", "Reload mango configuration", Category::System},
    };
}

// ─── Helpers ────────────────────────────────────────────────────────────────

static std::string str_lower(const std::string& s) {
    std::string out = s;
    std::transform(out.begin(), out.end(), out.begin(), ::tolower);
    return out;
}

static std::string build_search_text(const Keybinding& kb) {
    std::string s = str_lower(kb.function) + " " + str_lower(kb.description) + " " + str_lower(kb.key);
    for (auto& m : kb.modifiers)
        s += " " + str_lower(m);
    return s;
}

// ─── Category order ─────────────────────────────────────────────────────────

static const Category CATEGORY_ORDER[] = {
    Category::Media,
    Category::Screenshot,
    Category::Applications,
    Category::WindowManagement,
    Category::Focus,
    Category::Movement,
    Category::Workspaces,
    Category::Monitors,
    Category::Layout,
    Category::System,
};

// ─── UI building ────────────────────────────────────────────────────────────

struct AppData {
    GtkWidget* content_box;
    std::vector<GtkWidget*> sections;
    std::vector<std::vector<GtkWidget*>> rows_per_section;
};

static GtkWidget* create_key_label(const char* text) {
    GtkWidget* label = gtk_label_new(text);
    gtk_widget_add_css_class(label, "key");
    return label;
}

static GtkWidget* create_keybinding_row(const Keybinding& kb) {
    GtkWidget* row = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 12);
    gtk_widget_add_css_class(row, "keybinding-row");
    gtk_widget_set_margin_start(row, 8);
    gtk_widget_set_margin_end(row, 8);
    gtk_widget_set_margin_top(row, 4);
    gtk_widget_set_margin_bottom(row, 4);

    // Store search text as widget name
    std::string search_text = build_search_text(kb);
    gtk_widget_set_name(row, search_text.c_str());

    // Key combination box
    GtkWidget* key_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 4);
    gtk_widget_add_css_class(key_box, "key-combination");
    gtk_widget_set_halign(key_box, GTK_ALIGN_START);
    gtk_widget_set_size_request(key_box, 320, -1);

    for (size_t i = 0; i < kb.modifiers.size(); i++) {
        gtk_box_append(GTK_BOX(key_box), create_key_label(kb.modifiers[i].c_str()));
        if (i < kb.modifiers.size() - 1 || !kb.key.empty()) {
            GtkWidget* plus = gtk_label_new("+");
            gtk_widget_add_css_class(plus, "key-separator");
            gtk_box_append(GTK_BOX(key_box), plus);
        }
    }

    if (!kb.key.empty()) {
        gtk_box_append(GTK_BOX(key_box), create_key_label(kb.key.c_str()));
    }

    // Function name
    GtkWidget* func_label = gtk_label_new(kb.function.c_str());
    gtk_widget_add_css_class(func_label, "function-name");
    gtk_widget_set_halign(func_label, GTK_ALIGN_START);
    gtk_widget_set_size_request(func_label, 220, -1);
    gtk_label_set_xalign(GTK_LABEL(func_label), 0.0);

    // Description
    GtkWidget* desc_label = gtk_label_new(kb.description.c_str());
    gtk_widget_add_css_class(desc_label, "description");
    gtk_widget_set_halign(desc_label, GTK_ALIGN_START);
    gtk_widget_set_hexpand(desc_label, TRUE);
    gtk_label_set_ellipsize(GTK_LABEL(desc_label), PANGO_ELLIPSIZE_END);
    gtk_label_set_xalign(GTK_LABEL(desc_label), 0.0);

    gtk_box_append(GTK_BOX(row), key_box);
    gtk_box_append(GTK_BOX(row), func_label);
    gtk_box_append(GTK_BOX(row), desc_label);

    return row;
}

static GtkWidget* create_category_section(Category cat, const std::vector<Keybinding>& bindings,
                                           std::vector<GtkWidget*>& out_rows) {
    GtkWidget* section = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6);
    gtk_widget_add_css_class(section, "category-section");
    gtk_widget_add_css_class(section, category_css_class(cat));

    // Header with color accent bar + title
    GtkWidget* header = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10);
    gtk_widget_add_css_class(header, "category-header");

    GtkWidget* accent = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_size_request(accent, 4, 22);
    gtk_widget_add_css_class(accent, "category-accent");
    gtk_widget_add_css_class(accent, category_css_class(cat));

    GtkWidget* title = gtk_label_new(category_name(cat));
    gtk_widget_add_css_class(title, "category-title");
    gtk_widget_set_halign(title, GTK_ALIGN_START);

    // Count badge
    std::string count_str = std::to_string(bindings.size());
    GtkWidget* badge = gtk_label_new(count_str.c_str());
    gtk_widget_add_css_class(badge, "category-badge");
    gtk_widget_add_css_class(badge, category_css_class(cat));

    gtk_box_append(GTK_BOX(header), accent);
    gtk_box_append(GTK_BOX(header), title);
    gtk_box_append(GTK_BOX(header), badge);

    gtk_box_append(GTK_BOX(section), header);

    // Keybinding rows
    GtkWidget* rows_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2);
    gtk_widget_add_css_class(rows_box, "keybindings-container");

    for (auto& kb : bindings) {
        GtkWidget* row = create_keybinding_row(kb);
        gtk_box_append(GTK_BOX(rows_box), row);
        out_rows.push_back(row);
    }

    gtk_box_append(GTK_BOX(section), rows_box);
    return section;
}

static void on_search_changed(GtkSearchEntry* entry, gpointer user_data) {
    auto* data = static_cast<AppData*>(user_data);
    const char* raw = gtk_editable_get_text(GTK_EDITABLE(entry));
    std::string query = str_lower(raw ? raw : "");

    for (size_t i = 0; i < data->sections.size(); i++) {
        int visible_count = 0;
        for (auto* row : data->rows_per_section[i]) {
            const char* name = gtk_widget_get_name(row);
            bool show = query.empty() || (name && std::string(name).find(query) != std::string::npos);
            gtk_widget_set_visible(row, show);
            if (show) visible_count++;
        }
        gtk_widget_set_visible(data->sections[i], visible_count > 0);
    }
}

static gboolean on_key_pressed(GtkEventControllerKey* /*ctrl*/, guint keyval,
                                guint /*keycode*/, GdkModifierType /*state*/, gpointer user_data) {
    if (keyval == GDK_KEY_Escape) {
        auto* window = static_cast<GtkWindow*>(user_data);
        gtk_window_destroy(window);
        return TRUE;
    }
    return FALSE;
}

static void load_css() {
    GtkCssProvider* provider = gtk_css_provider_new();

    // Build list of candidate paths for styles/main.css
    std::vector<std::string> search_paths;

    // 1. User config: ~/.config/mango/styles/main.css
    const char* xdg_config = g_get_user_config_dir();
    if (xdg_config)
        search_paths.push_back(std::string(xdg_config) + "/mango/styles/main.css");

    // 2. Next to the executable: <exe_dir>/styles/main.css
    char buf[4096];
    ssize_t len = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
    std::string exe_dir;
    if (len > 0) {
        buf[len] = '\0';
        exe_dir = std::filesystem::path(buf).parent_path().string();
        search_paths.push_back(exe_dir + "/styles/main.css");
        // 3. One level up from exe (dev build layout): <exe_dir>/../styles/main.css
        search_paths.push_back(exe_dir + "/../styles/main.css");
    }

    // 4. System install: /usr/share/mango-cheatsheet/styles/main.css
    search_paths.push_back("/usr/share/mango-cheatsheet/styles/main.css");

    // 5. Relative to CWD (development convenience)
    search_paths.push_back("styles/main.css");
    search_paths.push_back("../styles/main.css");

    bool loaded = false;
    for (auto& path : search_paths) {
        if (std::filesystem::exists(path)) {
            gtk_css_provider_load_from_path(provider, path.c_str());
            loaded = true;
            break;
        }
    }

    if (!loaded) {
        g_warning("Could not find styles/main.css — using defaults");
    }

    gtk_style_context_add_provider_for_display(
        gdk_display_get_default(),
        GTK_STYLE_PROVIDER(provider),
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION
    );
}

static void activate(GtkApplication* app, gpointer /*user_data*/) {
    load_css();

    GtkWidget* window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Mango Keybinding Cheatsheet");
    gtk_window_set_default_size(GTK_WINDOW(window), 1100, 900);

    // Escape to quit
    GtkEventController* key_ctrl = gtk_event_controller_key_new();
    gtk_event_controller_set_propagation_phase(key_ctrl, GTK_PHASE_CAPTURE);
    g_signal_connect(key_ctrl, "key-pressed", G_CALLBACK(on_key_pressed), (gpointer)window);
    gtk_widget_add_controller(window, key_ctrl);

    // Main vertical layout
    GtkWidget* main_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_widget_add_css_class(main_box, "main-container");
    gtk_widget_set_hexpand(main_box, TRUE);
    gtk_widget_set_vexpand(main_box, TRUE);

    // ── Header ──
    GtkWidget* header_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4);
    gtk_widget_add_css_class(header_box, "header");

    GtkWidget* title = gtk_label_new("Mango Keybinding Cheatsheet");
    gtk_widget_add_css_class(title, "title");
    gtk_widget_set_halign(title, GTK_ALIGN_CENTER);

    GtkWidget* subtitle = gtk_label_new("Press Escape to quit  ·  Scroll to browse  ·  Type to search");
    gtk_widget_add_css_class(subtitle, "subtitle");
    gtk_widget_set_halign(subtitle, GTK_ALIGN_CENTER);

    gtk_box_append(GTK_BOX(header_box), title);
    gtk_box_append(GTK_BOX(header_box), subtitle);
    gtk_box_append(GTK_BOX(main_box), header_box);

    // ── Search ──
    GtkWidget* search_entry = gtk_search_entry_new();
    gtk_widget_add_css_class(search_entry, "search-field");
    gtk_widget_set_margin_start(search_entry, 24);
    gtk_widget_set_margin_end(search_entry, 24);
    gtk_widget_set_margin_top(search_entry, 8);
    gtk_widget_set_margin_bottom(search_entry, 8);
    gtk_box_append(GTK_BOX(main_box), search_entry);

    // ── Content area (scrolled) ──
    GtkWidget* scrolled = gtk_scrolled_window_new();
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled),
                                    GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
    gtk_widget_set_hexpand(scrolled, TRUE);
    gtk_widget_set_vexpand(scrolled, TRUE);

    GtkWidget* content_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 16);
    gtk_widget_add_css_class(content_box, "content-area");
    gtk_widget_set_margin_start(content_box, 24);
    gtk_widget_set_margin_end(content_box, 24);
    gtk_widget_set_margin_top(content_box, 12);
    gtk_widget_set_margin_bottom(content_box, 24);

    // Group keybindings
    auto keybindings = get_keybindings();
    std::map<Category, std::vector<Keybinding>> grouped;
    for (auto& kb : keybindings)
        grouped[kb.category].push_back(kb);

    // Build sections
    auto* app_data = new AppData{content_box, {}, {}};

    for (auto cat : CATEGORY_ORDER) {
        auto it = grouped.find(cat);
        if (it == grouped.end()) continue;

        std::vector<GtkWidget*> rows;
        GtkWidget* section = create_category_section(cat, it->second, rows);
        gtk_box_append(GTK_BOX(content_box), section);
        app_data->sections.push_back(section);
        app_data->rows_per_section.push_back(std::move(rows));
    }

    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scrolled), content_box);
    gtk_box_append(GTK_BOX(main_box), scrolled);

    // Connect search
    g_signal_connect(search_entry, "search-changed", G_CALLBACK(on_search_changed), app_data);

    gtk_window_set_child(GTK_WINDOW(window), main_box);
    gtk_window_present(GTK_WINDOW(window));
}

// ─── Main ───────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    GtkApplication* app = gtk_application_new("com.mango.cheatsheet", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), nullptr);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}

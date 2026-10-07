#include "my_application.h"
#include <cstdlib>
#include <cstdio>
#include <sys/stat.h>
#include <string>

int main(int argc, char** argv) {
  // If running in a Snap, ensure ~/.config/gtk-3.0/colors.css exists to silence GTK theme import warning
  const char* snap_user_data = std::getenv("SNAP_USER_DATA");
  if (snap_user_data != nullptr) {
    std::string config_dir = std::string(snap_user_data) + "/.config";
    std::string gtk_dir = config_dir + "/gtk-3.0";
    std::string colors_file = gtk_dir + "/colors.css";
    mkdir(config_dir.c_str(), 0755);
    mkdir(gtk_dir.c_str(), 0755);
    FILE* f = fopen(colors_file.c_str(), "a");
    if (f != nullptr) {
      fclose(f);
    }
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

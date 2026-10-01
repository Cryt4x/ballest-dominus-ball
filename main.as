// Plugin by CryT4x: a clear ball with the Dominus (Rocket League car) inside, a 3D model file (models/dominus.glb placed
// by models/dominus.txt), added to the Customize page through Cosmetic Kit (a dependency: see info.toml).

import bool AddBall(const string &in, const string &in, const string &in, const string &in, const string &in) from "cosmetic-kit";

void Main()
{
    string f = Plugins::Folder();
    AddBall("cryt4x.dominus", "Dominus", "", f + "dominus_preview.png", f + "models/dominus.txt");
}

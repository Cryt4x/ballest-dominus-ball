// Plugin by CryT4x: a clear ball with the Dominus (Rocket League car) inside, added to the Customize page through
// Cosmetic Kit (a dependency: see info.toml). The ball cosmetic itself has no model: the plugin draws the car
// (models/dominus.glb placed by models/dominus.txt) at the ball each frame and turns it the way the ball goes, up and
// down slopes and falls too, which a model's travel group can't (it keeps the car upright). On the Customize page it
// stands in the menu ball (Cosmetics::PreviewBall). Replays and ghosts show no custom balls, so it's only drawn at the
// player's own ball.

[Setting name="Tilt with the ball" description="Tilt the car up and down slopes and when falling, not only left and right"]
bool Tilt = true;

[Setting name="Most tilt" min=0 max=90 description="The steepest the car tilts up or down, in degrees"]
float MostTilt = 90;

import bool AddBall(const string &in, const string &in, const string &in, const string &in, const string &in) from "cosmetic-kit";

const string ID = "cryt4x.dominus";
const double BALL_RADIUS = 50;      // the race ball's (cm): models/dominus.txt is made for it
const double JUMP = 400;            // further than this in one frame is a respawn or restart, not travel
const double STEER = 10;            // how quickly the car turns to a new direction (per second)
const double MOVING = 30;           // cm/s: slower than this, the car keeps the way it faces

int car = 0;                        // the drawn car (0: none yet, or its map is gone)
int map = -1;
double lastX, lastY, lastZ;         // the ball last frame
bool haveLast = false;
double velX = 0, velY = 0, velZ = 0;   // the ball's velocity, smoothed so bumps and bounces don't shake the car
double yaw = 0, pitch = 0;          // the way the car faces (degrees)

void Main()
{
    AddBall(ID, "Dominus", "", Plugins::Folder() + "dominus_preview.png", "");
}

void Update(float dt)
{
    double x, y, z, radius, facing;
    if (Cosmetics::Equipped(Cosmetics::Ball) != ID)
        Hide();
    else if (Race::OnTrack() && !Replay::IsActive() && Race::BallPosition(x, y, z))
    {
        Follow(x, y, z, dt);
        Place(x, y, z, Tilt ? pitch : 0, yaw, 1);
        return;
    }
    else if (Cosmetics::PreviewBall(x, y, z, radius, facing))
        Place(x, y, z, 0, facing, radius / BALL_RADIUS);
    else
        Hide();
    haveLast = false;
}

// The ball moved to x, y, z: turn the car the way it's going.
void Follow(double x, double y, double z, float dt)
{
    if (haveLast && dt > 0)
    {
        double dx = x - lastX, dy = y - lastY, dz = z - lastZ;
        if (dx * dx + dy * dy + dz * dz < JUMP * JUMP)
        {
            double k = 1 - Math::pow(2.718, -STEER * dt);
            velX += (dx / dt - velX) * k;
            velY += (dy / dt - velY) * k;
            velZ += (dz / dt - velZ) * k;
        }
        else
            velX = velY = velZ = 0;   // respawned: start again from standing
    }
    lastX = x; lastY = y; lastZ = z;
    haveLast = true;

    double flat = Math::sqrt(velX * velX + velY * velY);
    if (flat > MOVING)
        yaw = Math::atan2(velY, velX) * 57.2958;
    if (flat + Math::abs(velZ) > MOVING)
        pitch = Math::atan2(velZ, flat) * 57.2958;
    else
        pitch = 0;
    if (pitch > MostTilt) pitch = MostTilt;
    if (pitch < -MostTilt) pitch = -MostTilt;
}

// The car at x, y, z, turned and scaled (made first if there's none yet: a new map takes the old one with it).
void Place(double x, double y, double z, double p, double yw, double scale)
{
    if (Host::MapNumber() != map)
    {
        car = 0;
        map = Host::MapNumber();
    }
    if (car == 0)
        car = Draw::Model(Plugins::Folder() + "models/dominus.txt");
    if (car == 0)
        return;
    if (!Draw::Move(car, x, y, z))
    {
        car = 0;                      // its actor is gone: make a new one next frame
        return;
    }
    Draw::Turn(car, p, yw, 0);
    Draw::Scale(car, scale);
    Draw::Show(car, true);
}

void Hide()
{
    if (car != 0)
        Draw::Show(car, false);
}

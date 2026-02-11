module working_title;
import raylib5;
import std::io;
import std::math;

const int SCREENW = 1280;   // Ikkunan leveys
const int SCREENH = 720;    // Ikkunan korkeus

// Nimetään tyyppi "float[<2>]" uudestaan. "Vec2" on kivempi kirjoittaa.
typedef Vec2 = float[<2>];

/*
Yksinkertainen Triangle-tyyppi
*/
struct Triangle
{
    Vec2 position;
    float speed;
}

/*
Globaalin "state" -muuttujan tyyppi.
Tänne täytyy listata kaikki, mitä halutaan tallettaa
state-muuttujaan.
*/
struct State
{
	Player player1;
	Player player2;
	Triangle triangle;
}

/*
Globaali muuttuja "state" pitää sisällään kaiken sellaisen data,
jota halutaan pitää frame-rajojen yli (lifetime = koko ohjelma).
*/
State state = {
    .player1 = {
        .position = {SCREENW/2 - 100, SCREENH/2},
        .speed    = 500
    },
    .player2 = {
        .position = {SCREENW/2 + 100, SCREENH/2},
        .speed    = 500
    },
    .triangle = {
        .position = {SCREENW/2, 100},
        .speed    = 200
    },
};

/*
Koko ohjelman main-funktio. Suoritus alkaa täältä ja päättyy tänne.
*/
fn int main(String[] args)
{
    init();

	while (!rl::windowShouldClose())
	{	
		update();
		draw();
	}

    exit();
	return 0;
}

/*
Suoritetaan kerran ohjelman alussa
*/
fn void init()
{
	rl::setTraceLogLevel(rl::TraceLogLevel.WARNING);
    rl::setTargetFPS(120);
	rl::initWindow(SCREENW, SCREENH, "Working title");
}

/*
Päivitetään pelin tila. Tämä suoritetaan siis kerran per frame.
*/
fn void update()
{
    /*
    Delta time eli "dt" on viime framesta kulunut aika sekunneissa.
    Tätä käytetään laskuissa, joissa täytyy ottaa huomioon pelin FPS.
    Näin varmistutaan siitä, että esim. fysiikka toimii samalla tavalla
    riippumatta pelin frameratesta.
    */
    float dt = rl::getFrameTime();

    Player* p1 = &state.player1; // Alias pelaaja 1:stä
    Player* p2 = &state.player2; // Alias pelaaja 2:sta
    Triangle* tri = &state.triangle; // Alias kolmiosta

    /*
    Liikutellaan pelaaja 1:tä (WASD)
    */
	if (rl::isKeyDown(rl::KEY_W)) p1.position.y  -= dt * p1.speed;
	if (rl::isKeyDown(rl::KEY_S)) p1.position.y  += dt * p1.speed;
	if (rl::isKeyDown(rl::KEY_A)) p1.position.x  -= dt * p1.speed;
	if (rl::isKeyDown(rl::KEY_D)) p1.position.x  += dt * p1.speed;

    /*
    Liikutellaan pelaaja 2:sta (nuolinäppäimet)
    */
	if (rl::isKeyDown(rl::KEY_UP))    p2.position.y  -= dt * p2.speed;
	if (rl::isKeyDown(rl::KEY_DOWN))  p2.position.y  += dt * p2.speed;
	if (rl::isKeyDown(rl::KEY_LEFT))  p2.position.x  -= dt * p2.speed;
	if (rl::isKeyDown(rl::KEY_RIGHT)) p2.position.x  += dt * p2.speed;

    /*
    AI-liike kolmiolle: liiku kohti lähintä pelaajaa
    */
    // Laske etäisyydet molempiin pelaajiin
    float dx1 = p1.position.x - tri.position.x;
    float dy1 = p1.position.y - tri.position.y;
    float dist1 = (float)math::sqrt((double)(dx1*dx1 + dy1*dy1));
    
    float dx2 = p2.position.x - tri.position.x;
    float dy2 = p2.position.y - tri.position.y;
    float dist2 = (float)math::sqrt((double)(dx2*dx2 + dy2*dy2));
    
    // Valitse lähin pelaaja
    Vec2 target = (dist1 < dist2) ? p1.position : p2.position;
    
    // Liiku kohti valittua pelaajaa
    float dx = target.x - tri.position.x;
    float dy = target.y - tri.position.y;
    float dist = (float)math::sqrt((double)(dx*dx + dy*dy));
    
    if (dist > 0.0)
    {
        // Normalisoi suunta ja liiku
        tri.position.x += (dx / dist) * tri.speed * dt;
        tri.position.y += (dy / dist) * tri.speed * dt;
    }

    const float PLAYER_RADIUS = 20.0;
    
    /*
    Törmäystarkistukset: pelaajat eivät voi mennä toistensa läpi
    */
    
    // Pelaaja 1 vs Pelaaja 2
    float p1p2_dx = p2.position.x - p1.position.x;
    float p1p2_dy = p2.position.y - p1.position.y;
    float p1p2_dist = (float)math::sqrt((double)(p1p2_dx*p1p2_dx + p1p2_dy*p1p2_dy));
    float min_dist = PLAYER_RADIUS * 2;
    
    if (p1p2_dist < min_dist && p1p2_dist > 0.0)
    {
        // Työnnä pelaajia erilleen
        double overlap = (double)min_dist - (double)p1p2_dist;
        double push_x = ((double)p1p2_dx / (double)p1p2_dist) * overlap * 0.5;
        double push_y = ((double)p1p2_dy / (double)p1p2_dist) * overlap * 0.5;
        
        p1.position.x -= (float)push_x;
        p1.position.y -= (float)push_y;
        p2.position.x += (float)push_x;
        p2.position.y += (float)push_y;
    }
    
    // Pelaaja 1 vs Triangle
    float p1tri_dx = tri.position.x - p1.position.x;
    float p1tri_dy = tri.position.y - p1.position.y;
    float p1tri_dist = (float)math::sqrt((double)(p1tri_dx*p1tri_dx + p1tri_dy*p1tri_dy));
    
    if (p1tri_dist < min_dist && p1tri_dist > 0.0)
    {
        double overlap = (double)min_dist - (double)p1tri_dist;
        double push_x = ((double)p1tri_dx / (double)p1tri_dist) * overlap * 0.5;
        double push_y = ((double)p1tri_dy / (double)p1tri_dist) * overlap * 0.5;
        
        p1.position.x -= (float)push_x;
        p1.position.y -= (float)push_y;
        tri.position.x += (float)push_x;
        tri.position.y += (float)push_y;
    }
    
    // Pelaaja 2 vs Triangle
    float p2tri_dx = tri.position.x - p2.position.x;
    float p2tri_dy = tri.position.y - p2.position.y;
    float p2tri_dist = (float)math::sqrt((double)(p2tri_dx*p2tri_dx + p2tri_dy*p2tri_dy));
    
    if (p2tri_dist < min_dist && p2tri_dist > 0.0)
    {
        double overlap = (double)min_dist - (double)p2tri_dist;
        double push_x = ((double)p2tri_dx / (double)p2tri_dist) * overlap * 0.5;
        double push_y = ((double)p2tri_dy / (double)p2tri_dist) * overlap * 0.5;
        
        p2.position.x -= (float)push_x;
        p2.position.y -= (float)push_y;
        tri.position.x += (float)push_x;
        tri.position.y += (float)push_y;
    }
    
    /*
    Wrap-around efekti pelaaja 1:lle
    */
    if (p1.position.x < -PLAYER_RADIUS) p1.position.x = SCREENW + PLAYER_RADIUS;
    if (p1.position.x > SCREENW + PLAYER_RADIUS) p1.position.x = -PLAYER_RADIUS;
    if (p1.position.y < -PLAYER_RADIUS) p1.position.y = SCREENH + PLAYER_RADIUS;
    if (p1.position.y > SCREENH + PLAYER_RADIUS) p1.position.y = -PLAYER_RADIUS;

    /*
    Wrap-around efekti pelaaja 2:lle
    */
    if (p2.position.x < -PLAYER_RADIUS) p2.position.x = SCREENW + PLAYER_RADIUS;
    if (p2.position.x > SCREENW + PLAYER_RADIUS) p2.position.x = -PLAYER_RADIUS;
    if (p2.position.y < -PLAYER_RADIUS) p2.position.y = SCREENH + PLAYER_RADIUS;
    if (p2.position.y > SCREENH + PLAYER_RADIUS) p2.position.y = -PLAYER_RADIUS;
    
    /*
    Wrap-around efekti kolmiolle
    */
    if (tri.position.x < -PLAYER_RADIUS) tri.position.x = SCREENW + PLAYER_RADIUS;
    if (tri.position.x > SCREENW + PLAYER_RADIUS) tri.position.x = -PLAYER_RADIUS;
    if (tri.position.y < -PLAYER_RADIUS) tri.position.y = SCREENH + PLAYER_RADIUS;
    if (tri.position.y > SCREENH + PLAYER_RADIUS) tri.position.y = -PLAYER_RADIUS;
}

/*
Piirretään frame pelin tilasta. Tämä tehdään kerran per frame (duh).
*/
fn void draw() 
{
	rl::beginDrawing();

    // defer tarkoittaa, että koodi ajetaan nykyisen scopen lopussa.
    defer rl::endDrawing();

    rl::clearBackground({25, 25, 25, 255}); // RGBA-arvo taustavärille
    
    Vec2 p1_pos = state.player1.position;
    Vec2 p2_pos = state.player2.position;
    Vec2 tri_pos = state.triangle.position;

    // Piirretään punainen ympyrä pelaaja 1:n paikalle
    rl::drawCircle(
        (int)p1_pos.x,
        (int)p1_pos.y,
        20,
        rl::RED
    );
    
    // Piirretään sininen ympyrä pelaaja 2:n paikalle
    rl::drawCircle(
        (int)p2_pos.x,
        (int)p2_pos.y,
        20,
        rl::BLUE
    );
    
    // Piirretään keltainen kolmio
    const float TRI_SIZE = 20.0;
    rl::drawPoly(
        {tri_pos.x, tri_pos.y},  // Keskipiste
        3,                        // 3 kulmaa = kolmio
        TRI_SIZE,                 // Säde
        0.0,                      // Rotaatio
        rl::YELLOW
    );
    
    rl::drawFPS(20, 20);
    
    // Näytetään pelaajien koordinaatit
    String coords1 = string::tformat("Player 1: (%.1f, %.1f)", p1_pos.x, p1_pos.y);
    rl::drawText(coords1.zstr_tcopy(), 20, 50, 20, rl::RED);
    
    String coords2 = string::tformat("Player 2: (%.1f, %.1f)", p2_pos.x, p2_pos.y);
    rl::drawText(coords2.zstr_tcopy(), 20, 80, 20, rl::BLUE);
    
    String coords3 = string::tformat("Triangle: (%.1f, %.1f)", tri_pos.x, tri_pos.y);
    rl::drawText(coords3.zstr_tcopy(), 20, 110, 20, rl::YELLOW);
}


// Suoritetaan kerran ohjelman lopussa
fn void exit()
{
	rl::closeWindow();
}
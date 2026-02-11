module working_title;
import raylib5;
import std::io;

const int SCREENW = 1280;   // Ikkunan leveys
const int SCREENH = 720;    // Ikkunan korkeus

// Nimetään tyyppi "float[<2>]" uudestaan. "Vec2" on kivempi kirjoittaa.
typedef Vec2 = float[<2>];

/*
Globaalin "state" -muuttujan tyyppi.
Tänne täytyy listata kaikki, mitä halutaan tallettaa
state-muuttujaan.
*/
struct State
{
	Player player1;
	Player player2;
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



    //const float PLAYER_RADIUS = 20.0;

    /*  kovat rajat
    if (p.position.x < PLAYER_RADIUS) p.position.x = PLAYER_RADIUS;
    if (p.position.x > SCREENW - PLAYER_RADIUS) p.position.x = SCREENW - PLAYER_RADIUS;
    if (p.position.y < PLAYER_RADIUS) p.position.y = PLAYER_RADIUS;
    if (p.position.y > SCREENH - PLAYER_RADIUS) p.position.y = SCREENH - PLAYER_RADIUS;
    */

     /*
    Wrap-around efekti: pelaaja tulee toiselta puolelta, kun menee
    reunan yli. Pelaajan säde on 20, joten pelaaja häviää kokonaan
    ennen kuin ilmestyy toiselta puolelta.
    */
    const float PLAYER_RADIUS = 20.0;
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
    
    /*
    Alias pelaajan paikasta. Tällä kertaa tyyppi on arvo eikä pointteri,
    sillä meidän ei tarvitse muuttaa pelaajan paikkaa, haluamme vain tietää sen.
    */
    Vec2 p1_pos = state.player1.position;
    Vec2 p2_pos = state.player2.position;

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
    
    rl::drawFPS(20, 20);
    
    // Näytetään pelaajien koordinaatit
    String coords1 = string::tformat("Player 1: (%.1f, %.1f)", p1_pos.x, p1_pos.y);
    rl::drawText(coords1.zstr_tcopy(), 20, 50, 20, rl::RED);
    
    String coords2 = string::tformat("Player 2: (%.1f, %.1f)", p2_pos.x, p2_pos.y);
    rl::drawText(coords2.zstr_tcopy(), 20, 80, 20, rl::BLUE);
}


// Suoritetaan kerran ohjelman lopussa
fn void exit()
{
	rl::closeWindow();
}


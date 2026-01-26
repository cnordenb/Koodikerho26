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
	Player player;
}

/*
Globaali muuttuja "state" pitää sisällään kaiken sellaisen data,
jota halutaan pitää frame-rajojen yli (lifetime = koko ohjelma).
*/
State state = {
    .player = {
        .position = {SCREENW/2, SCREENH/2},
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
	rl::initWindow(SCREENW, SCREENH, "Fuksivuosi");
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

    Player* p = &state.player; // Alias pelaajasta. Pelkkä tyyliseikka.

    /*
    Liikutellaan pelaajaa 
    */
	if (rl::isKeyDown(rl::KEY_W)) p.position.y  -= dt * p.speed;
	if (rl::isKeyDown(rl::KEY_S)) p.position.y  += dt * p.speed;
	if (rl::isKeyDown(rl::KEY_A)) p.position.x  -= dt * p.speed;
	if (rl::isKeyDown(rl::KEY_D)) p.position.x  += dt * p.speed;
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
    Vec2 p_pos = state.player.position; 

    // Piirretään punainen ympyrä pelaajan paikalle
    rl::drawCircle(
        (int)p_pos.x,
        (int)p_pos.y,
        20,
        rl::RED
    );
    
    rl::drawFPS(20, 20);
}


// Suoritetaan kerran ohjelman lopussa
fn void exit()
{
	rl::closeWindow();
}


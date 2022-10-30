#include <iostream>
#include <random>
using namespace std;
typedef long long ll;
typedef vector<ll> V;
#define rep(i, n) for (ll(i) = 0; (i) < (n); (i)++)
random_device rd;
mt19937_64 mt(rd());

ll get_rand(ll mn = 0, ll mx = 10) { return mn + mt() % (mx - mn + 1); }
ll get_rand(V v) { return v[mt() % v.size()]; }

int main(void) {
    // Your code here!
    V date_v = {20220926, 20220927, 20220928, 20220929, 20220930,
                20221001, 20221002, 20221003, 20221004, 20221005};

    rep(i, 500) {
        cout << get_rand(date_v) << "," << get_rand(1, 10) << ","
             << get_rand(100, 50000) << endl;
    }
}

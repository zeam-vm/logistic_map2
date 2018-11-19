#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{Env, Term, NifResult, Encoder};

const P: i64 = 6700417;
const MU: i64 = 22;

mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.LogisticMap2Nif",
    [
        ("benchmark_rust_single", 1, benchmark_rust_single),
    ],
    None
}


fn benchmark_rust_single<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let size: i64 = try!(args[0].decode());
    Ok((1..=size).collect::<Vec<i64>>().iter().map(|&x| (x, MU * x * (x + 1) % P)).collect::<Vec<(i64, i64)>>().encode(env))
}
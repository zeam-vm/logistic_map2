#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

extern crate rayon;
extern crate num_cpus;

use rustler::{Env, Term, NifResult, Encoder};
use rustler::Error::RaiseAtom;

use rayon::prelude::*;
use rayon::ThreadPool;
use rayon::ThreadPoolBuildError;

const P: i64 = 6700417;
const MU: i64 = 22;

/*
mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}
*/

rustler_export_nifs! {
    "Elixir.LogisticMap2Nif",
    [
        ("benchmark_rust_single", 1, benchmark_rust_single),
        ("benchmark_rust_multi", 1, benchmark_rust_multi),
        ("benchmark_rust_multi_tp", 1, benchmark_rust_multi_tp),
        ("benchmark_rust_multi_tp_ls", 1, benchmark_rust_multi_tp_ls),
    ],
    None
}

lazy_static! {
    static ref THREAD_POOL: ThreadPool = set_num_threads(num_cpus::get()).unwrap();
}


fn benchmark_rust_single<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let size: i64 = try!(args[0].decode());
    Ok((1..=size).collect::<Vec<i64>>().iter().map(|&x| (x, MU * x * (x + 1) % P)).collect::<Vec<(i64, i64)>>().encode(env))
}

fn benchmark_rust_multi<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let size: i64 = try!(args[0].decode());
    Ok((1..=size).collect::<Vec<i64>>().par_iter().map(|&x| (x, MU * x * (x + 1) % P)).collect::<Vec<(i64, i64)>>().encode(env))
}

fn set_num_threads(n: usize) -> Result<ThreadPool, ThreadPoolBuildError> {
  rayon::ThreadPoolBuilder::new().num_threads(n).build()
}

fn benchmark_rust_multi_tp<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let size: i64 = try!(args[0].decode());
    let result: Result<Vec<(i64, i64)>, ThreadPoolBuildError> = match set_num_threads(num_cpus::get()) {
    		Ok(pool) => pool.install(|| {
    				Ok((1..=size).collect::<Vec<i64>>().par_iter().map(|&x| (x, MU * x * (x + 1) % P)).collect::<Vec<(i64, i64)>>())
    		}),
    		Err(e) => Err(e),
    };
    match result {
    	Ok(r) => Ok(r.encode(env)),
    	Err(_e) => Ok(unsafe {RaiseAtom("thread pool cannot be initialized.").encode(env)}),
    }
}

fn benchmark_rust_multi_tp_ls<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let size: i64 = try!(args[0].decode());
    let pool = &*THREAD_POOL;
    let v: Vec<(i64,i64)> = pool.install(|| {
    	(1..=size).collect::<Vec<i64>>().par_iter().map(|&x| (x, MU * x * (x + 1) % P)).collect::<Vec<(i64, i64)>>()
    });
    Ok(v.encode(env))
}


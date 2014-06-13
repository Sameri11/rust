// Copyright 2012-2014 The Rust Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution and at
// http://rust-lang.org/COPYRIGHT.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

// ignore-android
// ignore-pretty: does not work well with `--test`

#![feature(quote)]
#![feature(managed_boxes)]

extern crate syntax;

use syntax::ext::base::ExtCtxt;

fn syntax_extension(cx: &ExtCtxt) {
    let e_toks : Vec<syntax::ast::TokenTree> = quote_tokens!(cx, 1 + 2);
    let p_toks : Vec<syntax::ast::TokenTree> = quote_tokens!(cx, (x, 1 .. 4, *));

    let a: @syntax::ast::Expr = quote_expr!(cx, 1 + 2);
    let _b: Option<@syntax::ast::Item> = quote_item!(cx, static foo : int = $e_toks; );
    let _c: @syntax::ast::Pat = quote_pat!(cx, (x, 1 .. 4, *) );
    let _d: @syntax::ast::Stmt = quote_stmt!(cx, let x = $a; );
    let _e: @syntax::ast::Expr = quote_expr!(cx, match foo { $p_toks => 10 } );

    let _f: @syntax::ast::Expr = quote_expr!(cx, ());
    let _g: @syntax::ast::Expr = quote_expr!(cx, true);
    let _h: @syntax::ast::Expr = quote_expr!(cx, 'a');

    let i: Option<@syntax::ast::Item> = quote_item!(cx, #[deriving(Eq)] struct Foo; );
    assert!(i.is_some());
}

fn main() {
}

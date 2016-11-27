//! Test crate that only prints "Hello World"

/// Say Hello to the world
pub fn hello_world() {
	println!("Hello World!!!");
}

/// Program entry point
pub fn main() {
	hello_world();
}

#[cfg(test)]
mod tests {
	#[test]
	fn test_dummy() {
		assert!(1==1);
	}
}

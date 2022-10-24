pub fn print_type_of<T>(_: &T) {
    debug!("{}", std::any::type_name::<T>())
}

pub fn retrieve_type_of<T>(_: &T) -> &str {
    std::any::type_name::<T>()
}

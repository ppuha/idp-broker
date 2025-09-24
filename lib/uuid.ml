Random.init 63

let generate () = Uuidm.v4_gen (Random.get_state ()) ()

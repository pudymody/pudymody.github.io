---
title: Converting GIFs to PowerPoint with Rust
date: 2019-12-15T21:54:36.727Z
toc: true
---
# Intro
Time ago browsing reddit i found the following meme, and i thought, this seems like a good excersice to practice some rust code. Although im going to do it only with gifs.

I assume you know how to [compile a rust project](https://doc.rust-lang.org/book/ch01-00-getting-started.html) and know some basic knowledge about programming. Mostly what a function and a loop are.

![When IOS keeps you from screen recording Netflix so you screenshot every frame and stitch it together in PowerPoint](/static/xmw75vj6pgf31.jpg)

Yep, thats right, im going to write a rust program that takes a gif and tries to map every frame to a different slide in a powerpoint file and have it animate. Why? Because why not?

# Building

First we need to create a new rust project, to do this, we are going to use the ```cargo new project``` command. This will create a new folder called project with a barebones rust app. Before coding a good idea is to think of the steps that are needed in a general sense. These are:

1. Read a GIF image
2. Get everyframe on its own and some gif metadata.
3. Create a powerpoint file putting every frame on its own slide
4. Save it
5. Profit

## Reading GIF
For steps 1 and 2, we are going to use the [image crate](https://crates.io/crates/image) to read the gif, split its frame and save them in separate JPG. To do this, we need to add the following line to the *Cargo.toml* file. This file is the one that handles our dependencies and some build configs. You can think of it as the *package.json* file from NodeJS but in Rust.

Reading the [docs of the image crate](https://docs.rs/image/0.22.3/image/gif/index.html), in the GIF section, we could find an example that reads each frame. Perfect for our task. We also find that each frame has a method to convert it to a "special" buffer, which has a *save_with_format* method, that allows us to save the frame with a custom format. We loop through each frame and save them with the given index. **This crate is awesome, with just ~8 lines, we could extract each frame of a gif and save them as a jpg file.**

*Yes, i know that the file name is hardcoded, but this is just a test for now, thats also why i didnt care about handling errors, and just assumed everything will be fine*

```rust
use image::gif::Decoder;
use image::AnimationDecoder;
use image::ImageFormat::JPEG;

use std::fs::File;

fn decode() {
    // Decode a gif into frames
    let file_in = File::open("giphy.gif").expect("Could not open file");
    let mut decoder = Decoder::new(file_in).expect("Could not create decoder");

    let frames = decoder.into_frames();
    let frames = frames.collect_frames().expect("error decoding gif");

    let mut i = 0;
    for f in frames {
        f.into_buffer().save_with_format(
            format!("dist/media/{}.jpg", i),
            JPEG
        ).expect("Could not save frame");
        i += 1;
    }
}
```

## Writing PowerPoint
Great, we can parse gif files, now we only need to write powerpoint files. As there isnt any crate to deal with this kind of files, or its open source alternative *OpenDocument*, we will try to write one OpenDocument file by hand. As its open source, we can read its [specification](https://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os.html). Now, to do this there are at least two ways. One, read the specs and try to write something that applies to it, and the other, the one that im going to use, is write a file with powerpoint and try to hack its content till it does what i want. **Remember**, this only works because this is just a silly experiment, **DONT** do this at production code.

OpenDocument files are just zip files with xml and plain text files inside. That makes them a lot easier to work. Well, that and that there is an official documentation about them. After creating one with two slides with full images in it, extracting it, playing around its files, recompressing it, i could make the [smallest valid file](https://github.com/pudymody/experiment-gif-to-powerpoint/tree/master/minimal-odp). The most important files are *styles.xml*, *content.xml* and *manifest.xml*. The first has all the styles needed, specially the size of the slide. The second has the content itself, the images per slide with its size and position. And the last one, a list of all the files that makes this document.

To make the document, first we will need to write the content of this files. To do this, im going to write them from pure strings, im not going to use any kind of "template engine" or xml writer, just pure interpolated strings.

We need to create the basic directory structure and the extra files that dont need any processing. To do this, we will write a function to do it. As they dont need processing we could put its content as static strings. This prevents us to extend or change it easily without recompiling the program, ~~but who needs that?~~

```rust
fn basicTemplate() {
    create_dir("dist").expect("Could not write template");
    create_dir("dist/media").expect("Could not write template");
    create_dir("dist/META-INF").expect("Could not write template");

    let meta = "...";

    let mut file_meta = File::create("dist/meta.xml").expect("Could not write file");
    file_meta.write( meta.as_bytes() ).expect("Could not write meta");

    let mime = "...";
    let mut file_mime = File::create("dist/mimetype").expect("Could not write mime");
    file_mime.write( mime.as_bytes() ).expect("Could not write mime");

    let settings = "...";
    let mut file_settings = File::create("dist/settings.xml").expect("Could not write settings");
    file_mime.write( settings.as_bytes() ).expect("Could not write settings");
}
```

Now its time to write our files that needs some logic. But to do this, we need to get how many frames our GIF has and which size they have. You may be thinking, *"but in our decode function we didnt return anything, we just only write the frames to disk"*. And you are absolutly right, so its time to modify it. First we need to change our function signature to return a tuple with three fields: how many frames, the height, the width. Then we need to get the image dimensions using the *dimensions* method of the decoder from the image crate. This to work needs the *ImageDecoder* trait to be imported, as its a function from it, so we also bring it to scope.

```rust
use image::ImageDecoder;
fn decode() -> (u64,f64,f64){
    // Decode a gif into frames
    let file_in = File::open("giphy.gif").expect("Could not open file");
    let mut decoder = Decoder::new(file_in).expect("Could not create decoder");

    let dim = decoder.dimensions();
    let frames = decoder.into_frames();
    let frames = frames.collect_frames().expect("error decoding gif");

    let mut i = 0;
    for f in frames {
        f.into_buffer().save_with_format(
            format!("dist/media/{}.jpg", i),
            JPEG
        ).expect("Could not save frame");
        i += 1;
    }

    return (i,0.0104166667 * dim.0 as f64,0.0104166667 * dim.1 as f64);
}
```
You may be thinking **WTF is that magic number multiplying there????!???**. Well, it turns out that PowerPoint, at least version 2007 cant deal with pixel units, so we have to convert them to inches. Yes, it seems that in 2007 people wanted to print slides Â¯\\\_(ãƒ„)_/Â¯. That number is the fraction to convert from pixels to inch at 96dpi.

Now we need to finally write the files, im not going to write all the function as its too much text, but just a piece of it to give an idea of what we are doing. Either way you can read the full code at the [repo](https://github.com/pudymody/experiment-gif-to-powerpoint)

```rust
fn processingTemplate( data: (u64, f64, f64) ) {
    // ......
    let mut metainf = String::from("<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
    <manifest:manifest xmlns:manifest='urn:oasis:names:tc:opendocument:xmlns:manifest:1.0'>
        <manifest:file-entry manifest:full-path='/' manifest:media-type='application/vnd.oasis.opendocument.presentation' />
        <manifest:file-entry manifest:full-path='META-INF/manifest.xml' manifest:media-type='text/xml' />
        <manifest:file-entry manifest:full-path='content.xml' manifest:media-type='text/xml' />
        <manifest:file-entry manifest:full-path='meta.xml' manifest:media-type='text/xml' />
        <manifest:file-entry manifest:full-path='settings.xml' manifest:media-type='text/xml' />
        <manifest:file-entry manifest:full-path='mimetype' manifest:media-type='text/plain' />
        <manifest:file-entry manifest:full-path='styles.xml' manifest:media-type='text/xml' />");

    for i in 0..data.0 {
        let metafile = format!("<manifest:file-entry manifest:full-path='media/{}.jpg' manifest:media-type='image/jpg' />", i);
        metainf.push_str( metafile.as_str() );
    }

    metainf.push_str("</manifest:manifest>");
    let mut file_manifest = File::create("dist/META-INF/manifest.xml").expect("Could not write file");
    file_manifest.write( metainf.as_bytes() ).expect("Could not write meta");
    // ......
}
```

First we create a string with the content of the file that we  dont need any logic. Then for each frame of the gif, we add an entry to the manifest. Finally we write the text at the end and write it to a file. If you are expecting some explanation of how to write the *content.xml* file, its the same approach, but changing the content that we write at each iteration of the loop. What is the meaning of each iteration?, I dont know, i only know that with that works, for more information you could read the specs, im not trying to write a full spec complaint writer, im just trying to play around with rust. But knowing *SVG/HTML/anyother xml markup language*, you cant get a pretty good idea of what everything means.

## Saving it
Having all the data needed written to a dist folder, its time to create the ODP file. As i have said before, ODP files are just ZIP files with this content. Lucky us, we have a [zip crate](https://crates.io/crates/zip) to solve this for us. Time to include it. As we did before, we only need to add ```zip = "0.5.3"``` to the *Cargo.toml* file. Reading the docs, we have already an example of writing a file, but the contents are given explicity. More reading and we found in the examples a [way to compress a folder](https://github.com/mvdnes/zip-rs/blob/master/examples/write_dir.rs).

Now to make everything work, we need to create our *main* function. Our starting point for our program. The only thing we need to do is call all our previous functions.
```rust
fn main(){
     // this is the function which writes the files without processing.
    basicTemplate();

    // this extracts and write the frames
    let info = decode();

    // this write the files that need logic
    processingTemplate(info);

    // compress the folder to a odp file
    compress();
}
```

Aaaaaand..... Nothing its working. Well, we have a presentation file but its not moving. Thats because we didnt allow the slides to move at the given speed of gif frames. But here is an interesting thing about animated GIFs, they dont have a constant fps, but every frame has a different "time in screen", and that time is in hundreth of seconds, yes, **hundreths**, not seconds nor miliseconds, **hundreds**. Once again, we have to modify our decode function to return a list of ordered delays of each frame instead of how many there are. Lucky us, the image create has a method to get this delay, so we only need to create a vector and push them to it. To do this, first we need to bring to scope the vector namespace. And after modifying this function, we need to also change our templates to reflect this delay in each slide in the *processingTemplate* function.

```rust
use std::vec::Vec;
fn decode() -> (Vec<u16>,f64,f64){
    // Decode a gif into frames
    let file_in = File::open("giphy.gif").expect("Could not open file");
    let mut decoder = Decoder::new(file_in).expect("Could not create decoder");

    let dim = decoder.dimensions();
    let frames = decoder.into_frames();
    let frames = frames.collect_frames().expect("error decoding gif");

    let mut delays: Vec<u16> = Vec::new();
    let mut i = 0;
    for f in frames {
        delays.push( f.delay().to_integer() );
        f.into_buffer().save_with_format(
            format!("dist/media/{}.jpg", i),
            JPEG
        ).expect("Could not save frame");
        i += 1;
    }

    return (delays,0.0104166667 * dim.0 as f64,0.0104166667 * dim.1 as f64);
}
```

Now THATS a real slide with a working timing. We could finish writing the app here and we would have a working GIF-to-powerpoint app, but the code has a lot of space to make improvements. So lets dive into it.

## Improving code
Do you see all those *expect* calls around the code? Thats a method of the type *Result* (also of the *Option* type, but here we are not dealing with them, but the concept its pretty similar). *Result* its a native rust type that allows you to deal with operations that could return an error. It have two variations, **Ok(value)**, which represents that the operation was successfull and has the value returned or **Err(e)** which means that there was an error and has the given error. What *expect* does is check if the Result is an error, and if it is one, it will panic and stop the execution of the program and print the message. Here is one of the places that we could improve, instead of panicking, we could return the error from the function and let the caller handle it. For this, we are going to first change the signature of the functions to return a Result. As we want to return a string with the error, we are going to use the *map_err* method of the Result type. What it does is check if the result is an error, and if it is, call a function with the error as the first parameter and change it to what the function returns. The concept of mapping, but just for the error part. Here you could return your custom error type, but for this a string is enough. Having said that, our decode function now looks like this.

```rust
fn decode() -> Result<(Vec<u16>,f64,f64), String>{
    // Decode a gif into frames
    let file_in = File::open("giphy.gif").map_err(|e| "Could not open file")?;
    let mut decoder = Decoder::new(file_in).map_err(|e| "Could not create decoder")?;

    let dim = decoder.dimensions();
    let frames = decoder.into_frames();
    let frames = frames.collect_frames().map_err(|e| "error decoding gif")?;

    let mut delays: Vec<u16> = Vec::new();
    let mut i = 0;
    for f in frames {
        delays.push( f.delay().to_integer() );
        f.into_buffer().save_with_format(
            format!("dist/media/{}.jpg", i),
            JPEG
        ).map_err(|e| "Could not save frame")?;
        i += 1;
    }

    return Ok( (delays,0.0104166667 * dim.0 as f64,0.0104166667 * dim.1 as f64) );
}
```

**But what are those ? question marks???**. Thats some syntatic sugar from rust that does the following. If the result is an err, return from the function with the given error. But if its an Ok value, assign it to the variable. Very handy, isnt it?.

Rust by default uses snake_case for its names, although this is not an improvement, lets change our *basicTemplate* and *processingTemplate* function names to *basic_template* and *processing_template* to remove some verbose when compiling.

You know what *0.0104166667* means because you have read it previously, but someone reading the code wont know, so lets extract it to a constant more explanatory.

```rust
/* ... */
const PIXEL_TO_IN:f64 = 0.0104166667;
return Ok( (delays, PIXEL_TO_IN * dim.0 as f64,PIXEL_TO_IN * dim.1 as f64) );
/* ... */
```

Currently our decode function has the gif file hardcoded and the destination folder hardcoded too. This is a bad practice, we could pass those arguments and let the function be a lot more useful, letting the user decide which file to read and where to save them. To do this, we need to bring to scope the PathBuf data type, and add the parameters to the function. After this changes, our decode functions looks like this.

```rust
use std::path::PathBuf;
fn decode( src: PathBuf, mut folder: PathBuf) -> Result<(Vec<u16>,f64,f64), String>{
    // Workaround to have some file to work with in the path
    folder.push("0");

    // Decode a gif into frames
    let file_in = File::open( src ).map_err(|_| "Could not open file")?;
    let decoder = Decoder::new(file_in).map_err(|_| "Could not create decoder")?;

    let dim = decoder.dimensions();
    let frames = decoder.into_frames();
    let frames = frames.collect_frames().map_err(|_| "error decoding gif")?;

    let mut delays: Vec<u16> = Vec::new();
    let mut i = 0;
    for f in frames {
        delays.push( f.delay().to_integer() );
        folder.set_file_name( i.to_string() );
        folder.set_extension("jpg");

        f.into_buffer().save_with_format(
            &folder,
            JPEG
        ).map_err(|_| "Could not save frame")?;
        i += 1;
    }

    const PIXEL_TO_IN:f64 = 0.0104166667;
    return Ok( (delays, PIXEL_TO_IN * dim.0 as f64,PIXEL_TO_IN * dim.1 as f64) );
}
```

As you can read the function is almost the same but with a lot more power given to the user. There are 2 things to remark here. First, as we are expecting a folder where to put the files, we need to push some "placeholder" filename, so we can work with the *set_file_name* and *set_extension* methods, otherwise we would be modifying our folder name. Thats why we push a "0" at the begining. Second, when we set the file name, we need to convert our int to a string, because it doesnt implement conversion to OsStr ( a valid string at os level ).

We can finally say that our decode function is in a pretty good shape. Lets move on to other improvements.


Our second improvements has more to do with performance that with code usability. Currently we write a lot of files to the disk, and then we read them to write a zip file. *Couldnt we write directly to the zip file?*. Well... Yes and no. Our template functions which write plain text files could, but in our decode function, the *save_with_format* only accepts a path to write to. So the only improvement we could do right now, is to modify our template functions to write directly to the zip file, and only read the frames from disk. For this task, we need to modify our *basic_template* and *processing_template* functions to recieve a ZipWriter object, which allows us to write directly to the zip file instead of the disk. This object needs to be a reference as we want to always work with the same zip file, and also we dont want our functions to take ownership of it, they only need to do some work on it. *You can read more about the Rust concept of ownership in the [rust book](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)*

```rust
fn basic_template<T>( file: &mut ZipWriter<T> ) -> Result<(), String> where T: Write+Seek {
    let options = FileOptions::default()
        .compression_method(zip::CompressionMethod::Stored)
        .unix_permissions(0o755);

    file.start_file_from_path( Path::new("meta.xml"), options).map_err(|_| "Could not create presentation")?;
    file.write(b"...").map_err(|_| "Could not create presentation")?;

    file.start_file_from_path( Path::new("mimetype"), options).map_err(|_| "Could not create presentation")?;
    file.write(b"...").map_err(|_| "Could not create presentation")?;

    file.start_file_from_path( Path::new("settings.xml"), options).map_err(|_| "Could not create presentation")?;
    file.write(b"...")
        .map_err(|_| "Could not create presentation")?;

    return Ok(());
}
```

Wooaah, thats a lot of syntax to digest in the function signature. Lets begin with the easier part first.  *where T: Write+Seek* thats a way to say "whenever you see T in this function signature, it means Write+Seek". And you may be thinking what is Write+Seek?. Thats a concept called traits, its the way in rust to define interfaces.

> An **interface** is a way of saying that you want some methods with a given name and signature in the type that implements it.

*Write+Seek* means that it implements the write AND seek traits. And from where does it comes the T argument? Thats a generic.

> A generic as you may have guessed its a way of saying *any type*.

We need it because the ZipWriter type is constructed with a generic to write, thats why we express it as *ZipWriter\<T\>*. In summary, what this signature is saying is the following: This function will get an argument of type ZipWriter which has a generic type T which implements the trait/interface Write AND Seek. Mixing generics with some traits, you could accept anything as long as it implements the interface you need, an excellent way of abstracting things and only rely on the important thing and not its implementation.

Finally we need to modify our main function to reflect all of our changes. As its a little long to explain step by step, im going to write comments in it.

```rust
fn main() -> Result<(), String>{

    // Create the zip file
    let presentation_file = File::create("presentation.odp").map_err(|_| "Could not create presentation file")?;
    let mut zip = ZipWriter::new(presentation_file);

    // Templates without processing
    basic_template(&mut zip)?;

    // Create directory to write frames and extract them
    create_dir("dist").map_err(|_| "Could not write template")?;
    create_dir("dist/media").map_err(|_| "Could not write template")?;
    let info = decode( PathBuf::from("giphy.gif"), PathBuf::from("dist/media/") )?;

    let options = FileOptions::default()
        .compression_method(zip::CompressionMethod::Stored)
        .unix_permissions(0o755);

    // Write each frame to the zip file
    let mut frame_path_in_zip = PathBuf::from("media/0.jpg");
    let mut frame_path = PathBuf::from("dist/media/0.jpg");
    for i in 0..info.0.len() {
        frame_path_in_zip.set_file_name( i.to_string() );
        frame_path_in_zip.set_extension("jpg");
        zip.start_file_from_path( &frame_path_in_zip, options).map_err(|_| "Could not save frame")?;

        frame_path.set_file_name( i.to_string() );
        frame_path.set_extension("jpg");
        let frame_content = read( &frame_path ).map_err(|_| "Could not save frame")?;
        zip.write( &frame_content ).map_err(|_| "Could not save frame")?;
    }

    // Remove all extracted frames
    remove_dir_all( PathBuf::from("dist/") ).map_err(|_| "Could not clean frames")?;

    // Write templates which has processing
    processing_template(&mut zip, info)?;

    // Return from function.
    return Ok(());
}
```

# Outro
After writing this post and its code, i found out that the transition wasnt working correctly. It seems that PowerPoint 2007 couldnt handle subsecond time delays for transitions using the ODP format, or at least i couldnt make it work. I tried with LibreOffice, but the presentation function didnt work for me, it stutter and lagged a lot. I decided to make it full ODP version, that is delete the px-to-in conversion and hope that sometime in the future, LibreOffice works for me. Thats because i didnt want to ditch this post and because i think that although it didnt work fully, it has some interesting points about rust and how to improve written code.

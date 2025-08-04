import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class CustomEventCard extends StatefulWidget {
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onPressed;
  final List<String>? items; // Assume items are base64 encoded strings
  final Uint8List? bytesImage;
  final int? dotsCount;
  final String? eventDate;
  final String? eventName;
  final String? eventDetails;
  final String? eventPrice;
  final String? elevatedText;
  final List<bool> isLoading;
  final int index;
  const CustomEventCard({
    Key? key,
    required this.index,
    required this.isLoading,
    this.onPageChanged,
    this.items,
    this.bytesImage,
    this.dotsCount,
    this.eventDate,
    this.eventName,
    this.eventDetails,
    this.eventPrice,
    this.onPressed,
    this.elevatedText,
  }) : super(key: key);

  @override
  State<CustomEventCard> createState() => _CustomEventCardState();
}

class _CustomEventCardState extends State<CustomEventCard> {
  int position = 0;
  List<bool> isLoading = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xff15212D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    // aspectRatio: 16 / 9,
                    // autoPlayCurve: Curves.fastOutSlowIn,
                    // enableInfiniteScroll: true,
                    // autoPlayAnimationDuration: Duration(milliseconds: 800),
                    //viewportFraction: 0.8,
                    onPageChanged: (index, _) {
                      setState(() {
                        position = index;
                        widget.onPageChanged?.call(index);
                      });
                    },
                  ),
                  items: widget.items?.map((item) {
                        Uint8List bytes;
                        try {
                          bytes = base64Decode(item);
                        } catch (e) {
                          bytes = Uint8List(0); // Invalid base64 string
                        }
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: bytes.isNotEmpty
                                    ? Image.memory(
                                        bytes,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                              "assets/Images/erclogo.png");
                                        },
                                      )
                                    : Image.asset("assets/Images/erclogo.png"),
                              ),
                            );
                          },
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ],
          ),
        ),
        Text(
          widget.eventDate!,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          widget.eventName!,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Text(
          widget.eventDetails!,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Text(
          widget.eventPrice!,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        widget.isLoading[widget.index]
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.elevatedText ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

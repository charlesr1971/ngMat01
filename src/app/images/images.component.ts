import { Component, OnInit, OnDestroy, Input } from '@angular/core';

import { Observable, Subscription, Subject } from 'rxjs';

import { HttpService } from '../services/http/http.service';

import { Image } from './../image/image.model';

@Component({
  selector: 'app-images',
  templateUrl: './images.component.html',
  styleUrls: ['./images.component.css']
})
export class ImagesComponent implements OnInit {

  images = [];
  subjectImages: Subject<any> = new Subject<any>();

  //images: Observable<Image[]>;

  //@Input() images: any[];

  /* images: any[] = [
    {
      "name": "Douglas  Pace"
    },
    {
      "name": "Mcleod  Mueller"
    },
    {
      "name": "Day  Meyers"
    },
    {
      "name": "Aguirre  Ellis"
    },
    {
      "name": "Cook  Tyson"
    }
  ]; */

  http: Subscription;

  constructor(private httpService: HttpService) { 
    
  }

  fetchData() {
    this.http = this.httpService.fetchImages().subscribe( (data: any) => {
      console.log(data);
      data.map( (item: any) => {
        const image = new Image({
          category: item['category'],
          src: item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description']
        });
        this.images.push(image);
      });
      console.log("this.images: ", this.images);
      this.subjectImages.next(this.images);
    });
  }

  ngOnInit() {
    setTimeout( () => {
      this.fetchData();
    });
  }

  ngOnDestroy() {
    if (this.http) {
      this.http.unsubscribe();
    }
  }

}

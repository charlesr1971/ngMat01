import { Component, OnInit, OnDestroy, Input, Inject } from '@angular/core';
import { Observable, Subscription, Subject } from 'rxjs';
import { DOCUMENT } from '@angular/common';

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

  http: Subscription;

  constructor(private httpService: HttpService,
    @Inject(DOCUMENT) document) { 
      
  }

  fetchData() {
    this.http = this.httpService.fetchImages().subscribe( (data: any) => {
      console.log("images.component: fetchData(): data ",data);
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          category: item['category'],
          src: item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          size: item['size'],
          likes: item['likes'],
          userToken: item['userToken'],
          createdAt: item['createdAt']
        });
        this.images.push(image);
      });
      this.images.sort(function(a, b) {
          const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
          return dateB - dateA;
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

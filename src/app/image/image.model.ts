/**
 * An image represents an image uploaded by a user
 */

import { uuid } from './../util/uuid';

export class Image {

    id: string;
    category: string;
    src: string;
    author: string;
    title: string;
    description: string;
    size: number;
    likes: number;
    userToken: string;
    createdAt: string;

    constructor(obj?: any) {

        this.id = obj && obj.id || uuid();
        this.category = obj && obj.category || null;
        this.src = obj && obj.src || null;
        this.author = obj && obj.author || null;
        this.title = obj && obj.title || null;
        this.description = obj && obj.description || null;
        this.size = obj && obj.size || 0;
        this.likes = obj && obj.likes || 0;
        this.userToken = obj && obj.userToken || null;
        this.createdAt = obj && obj.createdAt || null;

    }

}